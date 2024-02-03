// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyGovernanceToken is ERC20, Ownable {
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votingPower;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    event ProposalCreated(uint256 indexed id, address indexed proposer, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool inFavor);
    event ProposalExecuted(uint256 indexed proposalId);

    constructor(address initialOwner) ERC20("MyGovernanceToken", "MGT") Ownable(initialOwner) {
        // Assign initial tokens to the owner
        _mint(initialOwner, 1000000 * (10**decimals()));
    }

    function createProposal(string memory description) external onlyOwner {
        uint256 newProposalId = proposalCount + 1;
        proposals[newProposalId] = Proposal({
            id: newProposalId,
            proposer: msg.sender,
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        });

        emit ProposalCreated(newProposalId, msg.sender, description);
        proposalCount++;
    }

    function vote(uint256 proposalId, bool inFavor) external {
        require(balanceOf(msg.sender) > 0, "Must have tokens to vote");
        require(!proposals[proposalId].executed, "Proposal already executed");

        if (inFavor) {
            proposals[proposalId].votesFor += balanceOf(msg.sender);
        } else {
            proposals[proposalId].votesAgainst += balanceOf(msg.sender);
        }

        votingPower[msg.sender] += balanceOf(msg.sender);
        emit Voted(proposalId, msg.sender, inFavor);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(!proposals[proposalId].executed, "Proposal already executed");
        require(proposals[proposalId].votesFor > proposals[proposalId].votesAgainst, "Not enough votes in favor");

        proposals[proposalId].executed = true;
           emit ProposalExecuted(proposalId);
    }
}