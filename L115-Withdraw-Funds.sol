//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract withdrawFunds {
    function addFunds() public payable {
        require(msg.value > 0.01 ether);
    }

    function withdrawFund(address payable _to) public payable {
        _to.transfer(address(this).balance);
    }

    function withdrawFund2(address payable _to) public payable {
        bool sent = _to.send(address(this).balance);
        require(sent, "Failed!!!");
    }

    function withdrawFund3(address payable _to) public payable {
        (bool sent, /* bytes memory data*/) = _to.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
