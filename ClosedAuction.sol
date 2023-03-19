// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids; // Bid array allows each bidder to bid multiple times

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) pendingReturns; // Allowed withdrawals of previous bids

    error TooEarly(uint256 time);
    error TooLate(uint256 time);
    error AuctionEndAlreadyCalled();

    modifier onlyBefore(uint256 time) {
        if (block.timestamp >= time) revert TooLate(time);
        _;
    }
    modifier onlyAfter(uint256 time) {
        if (block.timestamp <= time) revert TooEarly(time);
        _;
    }

    constructor(
        uint256 biddingTime,
        uint256 revealTime,
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealTime;
    }

    function blind_a_bid(
        uint256 value,
        bool fake,
        bytes32 secret
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(value, fake, secret));
    }

    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd) {
        bids[msg.sender].push(
            Bid({blindedBid: blindedBid, deposit: msg.value})
        );
    }

    function reveal(
        //values, fakes and secrets are taking as of the same length of bids done by a single bidder
        uint256[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    ) external onlyAfter(biddingEnd) onlyBefore(revealEnd) {
        uint256 length = bids[msg.sender].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        uint256 refund; //contract is refunding the amount if it was revealed
        for (uint256 i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint256 value, bool fake, bytes32 secret) = (
                values[i],
                fakes[i],
                secrets[i]
            );
            if (
                bidToCheck.blindedBid !=
                keccak256(abi.encodePacked(value, fake, secret))
            ) {
                // Bid was not actually revealed.
                // Do not refund deposit.
                continue;
            }
            refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value)) {
                    refund -= value;
                }
            }
            // Make it impossible for the sender to re-claim
            // the same deposit.
            bidToCheck.blindedBid = bytes32(0);
        }
        payable(msg.sender).transfer(refund);
    }

    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            payable(msg.sender).transfer(amount);
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() external onlyAfter(revealEnd) {
        //If the auction has already been ended,
        // the function will stop running and the transaction will be reverted
        if (ended) revert AuctionEndAlreadyCalled();

        ended = true; //if not ended set ended = true
        beneficiary.transfer(highestBid); // and transfer the highest bid amount
    }

    //this function is called when a new bid with higher amount is bidded
    function placeBid(address bidder, uint256 value)
        internal
        returns (bool success)
    {
        // first checks whether the value of the bid is greater than the current highest bid. If it's not,
        //the function returns false to indicate that the bid was not successful.
        if (value <= highestBid) {
            return false;
        }

        //If the bid is successful, the function checks whether there was a previously highest bidder.
        // If there was, then the deposit of the previously highest bidder is refunded.
        //highestBidder != address(0) -> if highestBidder exists
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }
}
