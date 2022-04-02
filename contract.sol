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
        address payable creator;
        uint priceToBribe;
    }

    uint public priceToCreateCitizen = 0.1 ether;

    Citizen[] public citizens;

    uint public populationSize;

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

}

contract RomanLaws is TheRomanCitizen {

    mapping(uint => mapping(uint => bool)) alreadyVoted;

    uint timeToVote = 2 minutes;

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

    function newPriceToBribe(uint _newPriceToBribe, uint whoIs) external isTheCreator(whoIs) {
        citizens[whoIs].priceToBribe = _newPriceToBribe;
    }

    function bribeTheVote(uint ofWho, uint whichLaw, bool approveTheLaw) external payable {
        require(msg.sender != citizens[ofWho].creator);
        require(msg.value >= citizens[ofWho].priceToBribe);
        address payable x = citizens[ofWho].creator;
        citizens[ofWho].creator = payable(msg.sender);
        vote(whichLaw, ofWho, approveTheLaw);
        citizens[ofWho].creator = payable(x);
    }

}
