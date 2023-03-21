// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsurancePolicy {
    address public insuranceCompany;

    struct Policy {
        address policyholder;
        uint256 premiumAmount;
        uint256 coverageAmount;
        uint256 expirationTime;
        bool isClaimable;
        bool isExpired;
        bool isCancelled;
        uint256 premiumPaidTime;
        uint256 claimTime;
    }

    mapping(address => Policy) public policies;

    modifier onlyInsuranceCompany() {
        require(
            msg.sender == insuranceCompany,
            "Only insurance company has this access"
        );
        _;
    }

    constructor() {
        insuranceCompany = msg.sender;
    }

    function getPoliciy(
        address _patient,
        uint256 _premiumAmount,
        uint256 _coverageAmount,
        uint256 _expirationTime
    ) public payable onlyInsuranceCompany {
        policies[_patient] = Policy(
            _patient,
            _premiumAmount,
            _coverageAmount,
            _expirationTime,
            false,
            false,
            false,
            0,
            0
        );
    }

    function payPremium(address _patientAddress) public payable {
        Policy storage policy = policies[_patientAddress];

        require(msg.value == policy.premiumAmount, "Incorrect premium amount");
        require(!(policy.isExpired), "Policy has expired");
        require(!(policy.isCancelled), "Policy has been cancelled");
        require((policy.premiumPaidTime) == 0, "Premium has already been paid");

        policy.premiumPaidTime = block.timestamp;
    }

    function cancelPolicy(address _patientAddress) public{
        Policy storage policy = policies[_patientAddress];

        require(
            msg.sender == policy.policyholder,
            "Only policyholder can cancel policy"
        );
        require(!(policy.isExpired), "Policy has expired");
        require(!(policy.isCancelled), "Policy has already been cancelled");
        require((policy.premiumPaidTime) == 0, "Premium has already been paid");

        policy.isCancelled = true;
    }

    function fileClaim(address _patientAddress) public onlyInsuranceCompany {
        Policy storage policy = policies[_patientAddress];

        require(policy.isClaimable, "Claim is not yet available");
        require(!(policy.isCancelled), "Policy has been cancelled");
        require((policy.claimTime) == 0, "Claim has already been filed");

        policy.claimTime = block.timestamp;
    }

    function checkCoverage(address _patientAddress) public view returns (bool) {
        Policy storage policy = policies[_patientAddress];

        return
            policy.isClaimable &&
            !policy.isExpired &&
            !policy.isCancelled &&
            policy.claimTime > 0 &&
            policy.claimTime <= policy.expirationTime;
    }

    function expirePolicy(address _patientAddress) public {
        Policy storage policy = policies[_patientAddress];

        require(
            block.timestamp >= policy.expirationTime,
            "Policy has not yet expired"
        );

        policy.isExpired = true;
        policy.isClaimable = true;
    }

    function getRefund(address _patientAddress) public {
        Policy storage policy = policies[_patientAddress];

        require(policy.isCancelled, "Policy has not been cancelled");
        require(policy.premiumPaidTime > 0, "Premium has not been paid");

        payable(msg.sender).transfer(policy.premiumAmount);
    }

    function getCoverage(address _patientAddress) public {
        Policy storage policy = policies[_patientAddress];

        require(checkCoverage(_patientAddress), "Coverage not available");

        payable(msg.sender).transfer(policy.coverageAmount);
    }
}
