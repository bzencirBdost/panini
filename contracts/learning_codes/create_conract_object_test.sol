pragma solidity ^0.4.20;

//deneme ozeti
//contract'i variable olarak kullanma.
//not: string'lerde ve array'lerde calismiyor.

contract A {
    string name;
    string surname;
    uint byear;    
    function A(string _name, uint _byear) public {
        name = _name;
        surname = "bdost";
        byear = _byear;
    }
    
    function getName() public view returns(string) {
        return name;        
    }

    function getSurName() public view returns(string) {
        return surname;        
    }
    
    function getByear() public view returns(uint) {
        return byear;        
    }
    

    function setName(string _name) public {
        name = _name;        
    }

    function setByear(uint _byear) public {
        byear = _byear;        
    }
    
}

contract B {
    A a;
    string name;
    function B(string _name) public {
        a = new A(_name, 1234);
    }

/*
    function getNameA() public view returns(string) {
        string memory aName = a.getName();
        return a.getName();        
    }

    function getSurNameA() public view returns(string) {
        return a.getSurName();        
    }
*/
 
    function getByear() public view returns(uint) {
        return a.getByear();
    }

    function setByearA(uint _byear) public {
        a.setByear( _byear );
    }

}