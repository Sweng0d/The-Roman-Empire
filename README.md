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

Public commands like x have also been created which allow you to see how many people there are living in Rome
