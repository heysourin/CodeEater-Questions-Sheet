//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Test {
    function checkAddressType(
        address _addr
    ) public view returns (string memory) {
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

    function checkContract(address addr) public view returns (bool) {
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codehash;
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0 && codehash != accountHash); //returns true when a contractaddress has been passed
    }
}
