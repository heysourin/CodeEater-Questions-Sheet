// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract Bridge {
    address public tokenAddress;
    address public otherBridgeAddress;

    constructor(address _tokenAddress, address _otherBridgeAddress) {
        tokenAddress = _tokenAddress;
        otherBridgeAddress = _otherBridgeAddress;
    }

    function transferToOtherChain(address to, uint256 amount) external {
        IToken(tokenAddress).transfer(address(this), amount);
        bytes memory payload = abi.encodeWithSignature(
            "transferToThisChain(address,uint256)",
            to,
            amount
        );
        (bool success, ) = otherBridgeAddress.call(payload);
        require(success, "Transfer to other chain failed");
    }

    function transferToThisChain(address to, uint256 amount) external {
        IToken(tokenAddress).transfer(to, amount);
    }

    function setOtherBridgeAddress(address _otherBridgeAddress) external {
        otherBridgeAddress = _otherBridgeAddress;
    }

    function withdrawTokens(uint256 amount) external {
        IToken(tokenAddress).transfer(msg.sender, amount);
    }

    function withdrawETH() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
