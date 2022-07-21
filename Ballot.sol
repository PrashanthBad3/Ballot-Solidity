//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Ballot{
    // represents a single voter
    struct Voter{
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }
    struct Proposal{
        bytes32 name;
        uint voteCount;
    }

    address public chairPerson;

    mapping (address => Voter) public voters;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames){
        chairPerson = msg.sender;
        voters[chairPerson].weight=1;

        for (uint i=0; i<proposalNames.length; i++){
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
                }));
        }
    }

    function giveRightToAnswer(address voter) external{
        require(msg.sender == chairPerson, "Only ChairPerson can give right to vote");
        require(!voters[voter].voted, "The voter already voted");
        require(voters[voter].weight==0);
        
        voters[voter].weight = 1;
    }
// DELEGATE is a person selected to represent a group of people.
    function delegate(address to)external{
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0,"You have no right to vote");
        require(!sender.voted, "You already voted");

        require(to != msg.sender, "Self-Delegation is not allowed");

        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to!=msg.sender,"Found loop in delegation");
        }

        Voter storage delegate_ = voters[to];
        require(delegate_.weight >= 1);

        sender.voted = true;
        sender.delegate = to;
        
        if(delegate_.voted){
            proposals[delegate_.vote].voteCount +=sender.weight;
        }else{
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal)external{
    Voter storage sender = voters[msg.sender];
    require(sender.weight != 0, "Has no right to vote");
    require(!sender.voted, "Already voted");
    sender.voted = true;
    sender.vote=proposal;

    proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint winningProposal_){
        uint winningVotecount=0;
        for(uint i=0; i<proposals.length; i++){
            if (proposals[i].voteCount > winningVotecount){
                winningVotecount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    function winnerName() external view returns(bytes32 winnerName_){
        winnerName_ = proposals[winningProposal()].name;
    }
}