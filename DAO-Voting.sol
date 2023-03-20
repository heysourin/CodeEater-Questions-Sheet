// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO {
    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    IERC20 public token;
    address public admin;
    Proposal[] public proposals;

    mapping(address => bool) public hasVoted;
    mapping(uint256 => mapping(address => bool)) public hasVotedForProposal;

    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, bool inSupport, address voter);
    event ProposalExecuted(uint256 proposalId);

    constructor(IERC20 _token) {
        token = _token;
        admin = msg.sender;
    }

    function createProposal(string memory _description) public {
        proposals.push(Proposal(_description, 0, 0, false));
        emit ProposalCreated(proposals.length - 1, _description);
    }

    function vote(uint256 _proposalId, bool _inSupport) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.executed == false, "Proposal has already been executed.");
        require(hasVoted[msg.sender] == false, "You have already voted.");

        if (_inSupport) {
            proposal.votesFor += token.balanceOf(msg.sender);
            hasVotedForProposal[_proposalId][msg.sender] = true;
        } else {
            proposal.votesAgainst += token.balanceOf(msg.sender);
        }

        hasVoted[msg.sender] = true;
        emit Voted(_proposalId, _inSupport, msg.sender);
    }

    function executeProposal(uint256 _proposalId) public  {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.executed == false, "Proposal has already been executed.");
        require(
            token.balanceOf(msg.sender) >= proposal.votesFor + proposal.votesAgainst,
            "You must have a balance greater than the total number of votes to execute a proposal."
        );
        require(
            (proposal.votesFor > proposal.votesAgainst),
            "The votes against the proposal are greater than the votes for the proposal."
        );

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }

}
