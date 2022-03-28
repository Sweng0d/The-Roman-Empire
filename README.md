# The Roman Citizen
![image](https://user-images.githubusercontent.com/101097089/160344573-329cff6c-59b0-4a86-b6b3-6915b44cfaf5.png)

The idea of this project is to allow anyone to create a roman citizen, with all the benefits or disadvantages of each type of person at the time.  We are going to create a banking system as well, where you can lend or borrow money, and receive interest on it.

# Social Classes
![image](https://user-images.githubusercontent.com/101097089/160344630-ed15dd9a-4ed9-4aac-be8b-59ae90d7502c.png)

As we all know, ancient rome was divided into classes.
Therefore, the first part of our contract will be the creation of a Roman citizen, where he will have a name, age, social class and rights (which slaves and freedpeople obviously didn't have).

```
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
        Classes class; //new class, haverights bool
        bool haveRights;
    }

    Citizen[] public citizens;

    function create(string memory _name, uint _age, Classes _class) public {
        bool _haveRights;
        if (_class == Classes.Slaves || _class == Classes.Freedpeople){
            _haveRights = false;
        } else {
            _haveRights = true;
        }
        
        citizens.push(Citizen(_name, _age, _class, _haveRights));


    }

}
```

