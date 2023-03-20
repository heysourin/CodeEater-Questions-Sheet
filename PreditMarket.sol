//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract PredictMarket {
    enum Side {
        Biden,
        Trump
    }
    struct Result {
        Side winner;
        Side loser;
    }
    Result public result;

    bool public electionFinished;
    address public oracle;

    mapping(Side => uint256) public bets;
    mapping(address => mapping(Side => uint256)) public betsPerGambler;

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function placeBet(Side _side) external payable {
        require(electionFinished == false, "Election has been finished");
        bets[_side] += msg.value;
        betsPerGambler[msg.sender][_side] += msg.value;
    }

    function withdrawGain() external {
        uint256 gamblerBet = betsPerGambler[msg.sender][result.winner];
        require(gamblerBet > 0, "You do not have any winnig bet");
        require(electionFinished == true, "Election not finished yet");
        uint256 gain = gamblerBet +
            (bets[result.loser] * gamblerBet) /
            bets[result.winner];

        betsPerGambler[msg.sender][Side.Biden] = 0;
        betsPerGambler[msg.sender][Side.Trump] = 0;

        payable(msg.sender).transfer(gain);
    }

    function reportResult(Side _winner, Side _loser) external {
        require(oracle == msg.sender, "Only oracle");
        require(electionFinished == false, "Election already finished");
        result.winner = _winner;
        result.loser = _loser;
        electionFinished = true;
    }
}
