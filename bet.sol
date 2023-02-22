//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ATM.sol";

contract SportsBettingPlatform is Ownable {
    event NewBet(address adrs, uint256 amount, Team teamBet);

    struct Team {
        string name;
        uint256 totalBetAmount;
    }

    struct Bet {
        string name;
        address adrs;
        uint256 amount;
        Team teamBet;
    }


    Bet[] public bets;
    Team[] public teams;

    address payable conOwner;
    uint256 public totalBetMoney = 0;

    mapping(address => uint256) public numBetsAddress;

    constructor() payable {
        conOwner = payable(msg.sender); // setting the contract creator
        //There are 2 teams in the game
        teams.push(Team("team1", 0));
        teams.push(Team("team2", 0));
    }

    function createTeam(string memory _name) public {
        teams.push(Team(_name, 0));
    }

    function getTotalBetAmount(uint256 _teamId) public view returns (uint256) {
        return teams[_teamId].totalBetAmount;
    }

    function createBet(string memory _name, uint256 _teamId) external payable {
        require(msg.sender != conOwner, "owner can't make a bet");
        require(
            numBetsAddress[msg.sender] == 0,
            "you have already placed a bet"
        );
        require(msg.value > 0.01 ether, "Have to pay more that 0.01 ETH");

        bets.push(Bet(_name, msg.sender, msg.value, teams[_teamId]));

        if (_teamId == 0) {
            teams[0].totalBetAmount += msg.value;
        }
        if (_teamId == 1) {
            teams[1].totalBetAmount += msg.value;
        }

        numBetsAddress[msg.sender]++;

        (bool sent, /* bytes memory data*/) = conOwner.call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        totalBetMoney += msg.value;

        emit NewBet(msg.sender, msg.value, teams[_teamId]);
    }

    function teamWinDistribution(uint256 _teamId) public payable onlyOwner {
    //Accepts a single parameter _teamId, which specifies the winning team
        uint256 div;

        if (_teamId == 0) {
            for (uint256 i = 0; i < bets.length; i++) {
                if (
                    keccak256(abi.encodePacked((bets[i].teamBet.name))) ==
                    keccak256(abi.encodePacked("team1"))
                ) {
                    address receiver = payable(bets[i].adrs);
                    div =
                        (bets[i].amount *
                            (10000 +
                                ((getTotalBetAmount(1) * 10000) /
                                    getTotalBetAmount(0)))) /
                        10000;

                    (bool sent, /*bytes memory data*/) = receiver.call{value: div}(
                        ""
                    );
                    require(sent, "Failed to send Ether");
                }
            }
        } else {
            for (uint256 i = 0; i < bets.length; i++) {
                if (
                    keccak256(abi.encodePacked((bets[i].teamBet.name))) ==
                    keccak256(abi.encodePacked("team2"))
                ) {
                    address payable receiver = payable(bets[i].adrs);
                    div =
                        (bets[i].amount *
                            (10000 +
                                ((getTotalBetAmount(0) * 10000) /
                                    getTotalBetAmount(1)))) /
                        10000;

                    (bool sent, /*bytes memory data*/) = receiver.call{value: div}(
                        ""
                    );
                    require(sent, "Failed to send Ether");
                }
            }
        }

        totalBetMoney = 0;
        teams[0].totalBetAmount = 0;
        teams[1].totalBetAmount = 0;

        for (uint256 i = 0; i < bets.length; i++) {
            numBetsAddress[bets[i].adrs] = 0;
        }
    }
}
