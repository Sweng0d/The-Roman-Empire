# The Roman Empire
![image](https://user-images.githubusercontent.com/101097089/160344573-329cff6c-59b0-4a86-b6b3-6915b44cfaf5.png)

The idea of this project is to allow any ethereum address to create as many Roman citizens as desired, with all the benefits or disadvantages of each type of person at the time. As in ancient Rome, whoever is considered a Roman citizen (not all of them, hehe), can establish new ideas of laws, and if the law is democratically approved within the stipulated time, the law can be passed. So this idea of creating laws and voting will be the main point of our smart contract.

# Social Classes
![image](https://user-images.githubusercontent.com/101097089/160344630-ed15dd9a-4ed9-4aac-be8b-59ae90d7502c.png)

As we all know, ancient rome was divided into classes.
Therefore, the first part of our contract will be the creation of a Roman citizen, where he will have a name, age, social class and rights (which slaves and freedpeople obviously didn't have). 
Each ethereum address can create as many citizens as desired. And only you can control your citizen, voting or establishing new laws. It is worth mentioning that if you want to create a slave or a freedpeople, you cannot vote or establish any law.

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
![image](https://user-images.githubusercontent.com/101097089/160382928-d8e4236f-18d0-450e-95aa-5dcf46a9aabb.png)
The idea in terms of voting was to simulate Roman democracy at its peak. Allowing anyone who was considered a Roman citizen to create some idea of law, and other people, who had the rights, to vote on the laws.

However, we had to add several modifiers, and other functions to guarantee some concepts of democracy, such as:
- You can only vote with a citizen who belongs to you
- Any citizen with rights can create or vote on a law and its proposal
- There is a time to vote, if the time expires, the democratic result can be called, and after that, the law is approved
- A citizen can only vote once per law

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

# New Features

# Bribe

![image](https://user-images.githubusercontent.com/101097089/160547703-a8c01a11-9072-4482-aea7-bbbfd19deb7c.png)


How about bribery? 
We know that in a democracy, many people buy someone else's vote. So the idea here was to make it so that the owner of a citizen can put a price on his vote, and thus, someone can buy his vote for a certain law.
To do this, first we had to add a price to create a citizen, a feature that didn't exist before, otherwise it wouldn't make sense to buy someone's vote if you can just create a new citizen.
A new part of Struct was also created, called priceToBribe. And a function to allow the owner of the citizen to change its price.

    ```
    struct Citizen {
        string name;
        uint256 age;
        Classes class; 
        bool haveRights;
        address payable creator;
        uint priceToBribe;
    }
    
    uint public priceToCreateCitizen = 0.1 ether;
    
    function createCitizen(string memory _name, uint _age, Classes _class, uint priceToBribe) public payable {
        require (msg.value >= priceToCreateCitizen);
        bool _haveRights;
        if (_class == Classes.Slaves || _class == Classes.Freedpeople){
            _haveRights = false;
        } else {
            _haveRights = true;
        }
        
        citizens.push(Citizen(_name, _age, _class, _haveRights, payable(msg.sender) , priceToBribe));
        populationSize++;

    }
    
    function newPriceToBribe(uint _newPriceToBribe, uint whoIs) external isTheCreator(whoIs) {
        citizens[whoIs].priceToBribe = _newPriceToBribe;
    }
    
    ```
    
    After that, comes the bribe itself.
    In the bribe, you put some entries, like:
    - Which citizen do you want to bribe
    - Which law will you vote for?
    - Your vote
    And in the message.value you put the price of the bribery.
    
    The easiest way to do this, as there is a modifier that doesn't allow you to vote if you don't own the citizen is first to store who was the former owner in a variable "x", then change the owner of the citizen to whom he is bribing, perform the desired vote of the bribe, and then return the citizen to the initial owner, as we can see in the code below.
    
    ```
    function bribeTheVote(uint ofWho, uint whichLaw, bool approveTheLaw) external payable {
        require(msg.sender != citizens[ofWho].creator);
        require(msg.value >= citizens[ofWho].priceToBribe);
        address payable x = citizens[ofWho].creator;
        citizens[ofWho].creator = payable(msg.sender);
        vote(whichLaw, ofWho, approveTheLaw);
        citizens[ofWho].creator = payable(x);
    }
    
    ```
    
    









