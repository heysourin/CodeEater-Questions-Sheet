// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Token {
    mapping(address => uint256) balances;

    function transfer(
        address to,
        uint256 amount,
        uint256 nonce,
        uint256 gasPrice,
        uint256 gasLimit,
        bytes calldata signature
    ) external {
        bytes32 message = keccak256(
            abi.encodePacked(
                msg.sender,
                to,
                amount,
                nonce,
                gasPrice,
                gasLimit,
                address(this)
            )
        );
        address signer = ecrecover(
            message,
            uint8(signature[0]),
            bytes32(signature[1:33]),
            bytes32(signature[33:65])
        );

        require(signer == msg.sender, "Invalid signature");

        uint256 gasCost = gasPrice * gasLimit;
        require(
            balances[msg.sender] >= amount + gasCost,
            "Insufficient balance"
        );

        balances[msg.sender] -= amount + gasCost;
        balances[to] += amount;
    }
}
