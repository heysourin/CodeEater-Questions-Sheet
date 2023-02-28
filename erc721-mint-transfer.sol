//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ERC721TokenTransfer {
    string public name;
    string public symbol;
    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balances;

    uint256 tokenId;
    event Transfer(address from, address to, uint256 tokenId);

    function mintToken(address to) public {
        require(to != address(0));
        tokenId++; //tokenId will start from 1
        unchecked {
     
            balances[to] += 1;
        }
        owners[tokenId] = to;
    }

    function tokenTransferRaw(
        address from,
        address to,
        uint256 _tokenId
    ) public {
        require(to != address(0));
        require(from == msg.sender);
        unchecked {
            balances[from] -= 1;
            balances[to] += 1;
        }
        delete owners[_tokenId];
        owners[_tokenId] = to;
    }
}
