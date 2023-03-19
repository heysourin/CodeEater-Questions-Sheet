//SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

contract Escrow {
    address public payer;
    address public payee;
    address public arbiter;
    uint256 public amount;
    bool public disputed;

    constructor(
        address _payer,
        address _payee,
        address _arbiter,
        uint256 _amount
    ) {
        payer = _payer;
        payee = _payee;
        arbiter = _arbiter;
        amount = _amount;
    }

    function release() public {
        require(
            msg.sender == payee || msg.sender == arbiter,
            "Only the payee or arbiter can release funds"
        );
        require(disputed == false, "Funds have already been released");

        payable(payee).transfer(amount);
    }

    function dispute() public {
        require(
            msg.sender == payer || msg.sender == payee,
            "Only the payer or payee can dispute the transaction"
        );
        require(!disputed, "Transaction is already being disputed");
        disputed = true;
    }

    function resolve() public {
        require(
            msg.sender == arbiter,
            "Only the arbiter can resolve a dispute"
        );
        require(disputed, "Transaction is not being disputed");
        payable(payer).transfer(amount);
        disputed = false;
    }
}
