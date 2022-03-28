# The Roman Empire
![image](https://user-images.githubusercontent.com/101097089/160344573-329cff6c-59b0-4a86-b6b3-6915b44cfaf5.png)

The idea of this project is to allow any ethereum address to create as many Roman citizens as desired, with all the benefits or disadvantages of each type of person at the time. As in ancient Rome, whoever is considered a Roman citizen (not all of them, hehe), can establish new ideas of laws, and, if whoever has the right to vote approves the law, the law takes effect. So this idea of creating laws and voting will be the main point of our smart contract

# Social Classes
![image](https://user-images.githubusercontent.com/101097089/160344630-ed15dd9a-4ed9-4aac-be8b-59ae90d7502c.png)

As we all know, ancient rome was divided into classes.
Therefore, the first part of our contract will be the creation of a Roman citizen, where he will have a name, age, social class and rights (which slaves and freedpeople obviously didn't have). 
Each ethereum address can create as many citizens as desired. And only you can control your citizen, voting or establishing new laws. It is worth mentioning that if you want to create a Slave or a freedpeople, you cannot vote or establish any law.

```
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

contract TheRomanCitizen {
    enum Classes {
        Slaves,
        Freedpeople,
        Plebians,
        Equestrians,
        Patricians,
        Emperor
    }

    struct Citizen {
        string name;
        uint256 age;
        Classes class; 
        bool haveRights;
        address creator;
    }

    Citizen[] public citizens;

    uint public populationSize;

    function createCitizen(string memory _name, uint _age, Classes _class) public {
        bool _haveRights;
        if (_class == Classes.Slaves || _class == Classes.Freedpeople){
            _haveRights = false;
        } else {
            _haveRights = true;
        }
        
        citizens.push(Citizen(_name, _age, _class, _haveRights, msg.sender));
        populationSize++;

    }

}
```

Public commands like populationSize have also been created which allow you to see how many people there are living in Rome.

# Democracy and Voting
![image](https://user-images.githubusercontent.com/101097089/160381080-37d8cd60-cb1e-43d7-8a50-554c2d2005c8.png)
The idea in terms of voting was to simulate Roman democracy at its peak. Allowing anyone who was considered a Roman citizen to create some idea of ​​law, and other people, who had the rights, to vote on the laws.

However, we had to add several modifiers, and other functions to guarantee some concepts of democracy, such as:
-You can only vote with a citizen who belongs to you.
-Any citizen with rights can create a law and its proposal.
-There is a time to vote, if the time expires, the democratic result can be called, and after that, the law is approved.
-A citizen can only vote once per law

```
contract RomanLaws is TheRomanCitizen {

    mapping(uint => mapping(uint => bool)) alreadyVoted;

    uint timeToVote = 2 days;

    struct LawsProposed{
        string nameOfTheLaw;
        string whatItDoes;
        bool approved;
        uint timeTotalToVote;
        uint votesInFavor;
        uint votesAgainst;
    }

    LawsProposed[] public lawsProposed;

    modifier isTheCreator(uint whoIsProposing) {
        require(msg.sender == citizens[whoIsProposing].creator, "Not the creator of this citizen.");
        _;
    }

    modifier doYouHaveRights(uint whoIsProposing) {
        require(citizens[whoIsProposing].haveRights == true, "This citizen does not have rights to do that");
        _;
    }

    modifier haveTimeToVote(uint numberOfTheLaw) {
        require(lawsProposed[numberOfTheLaw].timeTotalToVote > block.timestamp, "the time is over!");
        _;
    }

    function proposeLaw(string memory _nameOfTheLaw, string memory _whatItDoes, uint _whoIsProposing)
     public isTheCreator(_whoIsProposing) doYouHaveRights(_whoIsProposing) {
         lawsProposed.push(LawsProposed(_nameOfTheLaw, _whatItDoes, false, block.timestamp + timeToVote, 0, 0));
    }

    function vote(uint _numberOfTheLaw, uint _whoIsVoting, bool approveTheLaw)
     public isTheCreator(_whoIsVoting) doYouHaveRights(_whoIsVoting) haveTimeToVote(_numberOfTheLaw) returns (string memory x) {
        require(alreadyVoted[_whoIsVoting][_numberOfTheLaw] == false, "already voted!");
        
        if (approveTheLaw == true) {
            lawsProposed[_numberOfTheLaw].votesInFavor ++;
        } else {
            lawsProposed[_numberOfTheLaw].votesAgainst ++;
        }

        alreadyVoted[_whoIsVoting][_numberOfTheLaw] = true;

        x = "you just voted!";
    }

    function timeIsOver(uint _numberOfTheLaw) public returns(string memory approvedOrNot){
        require(lawsProposed[_numberOfTheLaw].timeTotalToVote < block.timestamp, "The time is not over");
        if (lawsProposed[_numberOfTheLaw].votesInFavor > lawsProposed[_numberOfTheLaw].votesAgainst) {
            lawsProposed[_numberOfTheLaw].approved = true;
            approvedOrNot = "The law was approved!";
        } else {
            lawsProposed[_numberOfTheLaw].approved = false;
            approvedOrNot = "The law was not approved!";
        }
    }
}
```

-You can only vote with a citizen who belongs to you.
