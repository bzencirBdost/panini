pragma solidity ^0.4.21;

contract A {
    
    uint256 data;
    address public testAddress;
    uint256 public test2;
    function A() public {
        data = 1;
    }
    
    function getData() public view returns(uint256) {
        return data;
    }

    function setData(uint256 _data) public {
        data = _data;
    }
    
    function testThis(address _address) public {
        testAddress = _address;
    }


    function getTest2() public view returns(uint256) {
        return test2;
    }

    //diyelim ki B A dan turedi. Bu metodu overwrite ettim. 
    //A objesini B'nin adresi ile kullanan X contractinda nasil davranir?
    //cevap: A bir interface gibi davraniyor. B'nin metodunu cagirdi.
    function Test2() public {
        test2 = 1;
    }
    
    
}

contract X {
    A a;
    function X(address _a) public {
        a = A(_a);
    }

    function getData() public view returns(uint256) {
        return a.getData();
    }

    function setData(uint256 _data) public {
        a.setData(_data);
    }


    function Test2() public {
        a.Test2();
    }
    

    function getTest2A() public view returns(uint256) {
        return a.getTest2();
    }

}


contract B is A {
    X x;    
    function B() public {
        data = 2;
    }

    function setX(address _x) public {
        x = X(_x);
    }


    function getDataX() public view returns(uint256) {
        return x.getData();
    }

    function setDataX(uint256 _data) public {
        x.setData(_data);
    }

    function testThiss() public {
        testThis(address(this));
    }
    
    function Test2() public {
        test2 = 2;
    }

}
