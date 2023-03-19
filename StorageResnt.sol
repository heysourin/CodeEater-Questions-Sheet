// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

contract RentableStorage {
    address public owner;
    uint256 public costOfOneToken;
    // uint256 public storagePerByteCost;

    mapping(address => uint256) public numOfOwnedTokens;
    mapping(address => uint256) public storageSpace;

    constructor(uint256 _costOfOneToken) {
        owner = msg.sender;
        costOfOneToken = _costOfOneToken; //Weth
    }

    function buyTokens(uint256 _numOfTokensYouWant) public payable {
        require(
            msg.value >= costOfOneToken * _numOfTokensYouWant,
            "Pay the correct amount to buy the tokens"
        );
        numOfOwnedTokens[msg.sender] += _numOfTokensYouWant;
    }

    function rentStorage(uint256 _bytesStorageYouWant) public {
        require(numOfOwnedTokens[msg.sender] > _bytesStorageYouWant);
        numOfOwnedTokens[msg.sender] -= _bytesStorageYouWant;

        storageSpace[msg.sender] += _bytesStorageYouWant;
    }

    function releaseStorage(uint256 _bytesReleasing) public {
        require(storageSpace[msg.sender] > 0, "Storage doesnot even exists");
        storageSpace[msg.sender] += 0;

        numOfOwnedTokens[msg.sender] += _bytesReleasing;
    }

    function withdraw() public payable {
        payable(owner).transfer(address(this).balance);
    }
}
