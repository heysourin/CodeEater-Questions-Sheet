// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedIdentity {
    address public authority;
    struct Identity {
        string name;
        uint256 createdTimestamp;
        bool isVerified;
    }

    constructor(){
        authority = msg.sender;
    }

    modifier onlyAuthority(){
        require(msg.sender == authority);
        _;
    }

    mapping(address => Identity) public identities;

    function createIdentity(string memory _name) public onlyAuthority{
        require(bytes(_name).length > 0, "Name cannot be empty.");
        require(
            identities[msg.sender].createdTimestamp == 0,
            "Identity already exists."
        );

        Identity memory identity = Identity(_name, block.timestamp, false);
        identities[msg.sender] = identity;
    }

    function verifyIdentity(address _address) public onlyAuthority{
        require(
            msg.sender == _address,
            "You can only verify your own identity."
        );
        identities[_address].isVerified = true;
    }

    function getIdentity(address _address)
        public
        view
        returns (
            string memory,
            uint256,
            bool
        )
    {
        Identity memory identity = identities[_address];
        return (identity.name, identity.createdTimestamp, identity.isVerified);
    }
}
