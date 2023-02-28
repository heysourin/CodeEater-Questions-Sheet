//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ERC20TokenTransfer {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    // mapping(address => mapping(address => uint256)) public _allowances;
    mapping(address => uint256) public balances;

    event Transfer(address from, address to, uint256 amount);

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
    }

    function tokenFunctionRaw(
        address _to,
        address _from,
        uint256 _amount
    ) public {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = balances[_from];
        require(
            fromBalance >= _amount,
            "ERC20: transfer amount exceeds balance"
        );

        unchecked {
            balances[_from] = fromBalance - _amount;
            balances[_to] += _amount;
        }

        emit Transfer(_from, _to, _amount);
    }
}
