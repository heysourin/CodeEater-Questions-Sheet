//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Test {
    function checkAddressType(address _addr)
        public
        view
        returns (string memory)
    {
        uint256 codeSize;

        assembly {
            codeSize := extcodesize(_addr)
        }

        if (codeSize == 0) {
            return "Externally Owned Account";
        } else if (codeSize > 0) {
            return "Contract Account";
        } else {
            return "None";
        }
    }

    // function checkEAOCallingOrNot() public view returns (bool) {
    //     require(msg.sender == tx.origin, "Not an EOA");
    //     return true;
    // }

    function checkContract(address addr) public view returns (bool) {
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codehash;
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0 && codehash != accountHash); //returns true when a contractaddress has been passed
    }
}


/*
  The extcodesize opcode is a built-in EVM opcode that retrieves the size of the code of the contract located at the given address _addr.
It returns an integer value that represents the size of the contract's bytecode in bytes.

  By checking whether the codeSize variable is greater than zero, you can determine whether the address corresponds to a contract (codeSize > 0)
or an externally owned account (codeSize == 0). If the codeSize is zero, then the address is an externally owned account (EOA), which means it is
owned by a user and does not contain any contract bytecode. If the codeSize is greater than zero, then the address is a contract.
*/
