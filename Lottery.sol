//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address[] public players;
    uint public ticketPrice;
    uint public winnerIndex;
    bool public lotteryOpen;
    
    constructor(uint _ticketPrice) {
        manager = msg.sender;
        ticketPrice = _ticketPrice;
        lotteryOpen = true;
    }
    
    function buyTicket() public payable {
        require(msg.value >= ticketPrice, "Invalid ticket price");
        require(lotteryOpen == true, "Lottery is closed");
        
        players.push(msg.sender);
    }
    
    function closeLottery() public returns(uint){
        require(msg.sender == manager, "Only manager can close the lottery");
        require(lotteryOpen == true, "Lottery is already closed");
        
        uint numOfPlayers = players.length;
        require(numOfPlayers > 0, "No players participated in the lottery");
        
        winnerIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players))) % numOfPlayers;
        
        lotteryOpen = false;

        return winnerIndex;
    }
    
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
    
    function getWinner() public view returns (address) {
        require(lotteryOpen == false, "Lottery is still open");
        return players[winnerIndex];
    }

    function withDraw() public payable{
        require(msg.sender == manager, "Only manager can transfer");
        payable(players[winnerIndex]).transfer(address(this).balance);
    }
}
