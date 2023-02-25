// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract MusicStreamingPlatform {
    struct Song {
        string title;
        string artist;
        uint256 length;
        string genre;
        uint256 streamCount;
        address owner;
    }

    mapping(address => mapping(uint256 => bool)) public userPlaylists;
    mapping(address => uint256) public userRewards;
    mapping(uint256 => Song) public songs;

    uint256 public songCount;

    event SongAdded(uint256 songId, string title, string artist);

    function addSong(
        string memory _title,
        string memory _artist,
        uint256 _length,
        string memory _genre
    ) public returns (uint256) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_artist).length > 0, "Artist cannot be empty");
        require(_length > 0, "Song length must be greater than 0");
        require(bytes(_genre).length > 0, "Genre cannot be empty");

        uint256 newSongId = songCount++;

        songs[newSongId] = Song({
            title: _title,
            artist: _artist,
            length: _length,
            genre: _genre,
            streamCount: 0,
            owner: msg.sender
        });

        emit SongAdded(newSongId, _title, _artist);

        return newSongId;
    }

    function addToPlaylist(uint256 _songId) public {
        require(songs[_songId].owner != address(0), "Song does not exist");
        require(!userPlaylists[msg.sender][_songId], "Song already in playlist");

        userPlaylists[msg.sender][_songId] = true;
    }

    function removeFromPlaylist(uint256 _songId) public {
        require(songs[_songId].owner != address(0), "Song does not exist");
        require(userPlaylists[msg.sender][_songId], "Song not in playlist");

        userPlaylists[msg.sender][_songId] = false;
    }

    function streamSong(uint256 _songId) public {
        require(songs[_songId].owner != address(0), "Song does not exist");

        Song storage song = songs[_songId];

        song.streamCount++;
        userRewards[song.owner]++;
    }
}
