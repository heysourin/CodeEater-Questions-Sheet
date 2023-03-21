//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVesting {
    IERC20 public token;
    address public beneficiary;
    uint256 public start;
    uint256 public cliff; // time of no benefits
    uint256 public duration;
    bool public revocable;

    mapping(address => uint256) public released;
    mapping(address => bool) public revoked;

    event Released(uint256 amount);

    constructor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliffDuration,
        uint256 _duration,
        bool _revocable,
        address _token
    ) {
        require(_beneficiary != address(0));
        require(_start > 0);
        require(_cliffDuration <= _duration);

        beneficiary = _beneficiary;
        revocable = _revocable;
        token = IERC20(_token);
        duration = _duration;
        cliff = _start + _cliffDuration;
        start = _start;
    }

    function release() public {
        uint256 unreleased = releasableAmount();

        require(unreleased > 0);

        released[msg.sender] = released[msg.sender] + unreleased;

        token.transfer(beneficiary, unreleased);

        emit Released(unreleased);
    }

    function revoke() public {
        require(revocable);
        require(!revoked[msg.sender]);

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = releasableAmount();
        uint256 refund = balance - unreleased;

        revoked[msg.sender] = true;

        token.transfer(msg.sender, refund);
    }

    function releasableAmount() public view returns (uint256) {
        return vestedAmount() - released[msg.sender];
    }

    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance + released[msg.sender];

        if (block.timestamp < cliff) {
            return 0;
        }
        //time over or has been received the vested amount
        else if (block.timestamp >= start + duration || revoked[msg.sender]) {
            return totalBalance;
        } else {
            return (totalBalance * (block.timestamp - start)) / duration; //current num of tokens beneficiary gonna receive
        }
    }
}

/*
This smart contract solves the problem of distributing tokens to a beneficiary gradually
over a period of time, rather than all at once. It provides a mechanism for vesting tokens,
which can be useful in scenarios where a beneficiary needs to earn or demonstrate a
long-term commitment before receiving full ownership of the tokens.

For example, a startup may use a token vesting contract to distribute tokens to its 
founders over a period of several years, with a cliff period before any tokens are 
vested. This incentivizes the founders to stay with the company for the long term and 
work towards its success. Similarly, a company may use a token vesting contract to 
distribute tokens to its employees as a form of compensation or incentive.
*/
