pragma solidity ^0.4.21;
//B'nin metodlarini A'dan cagirinca +2.1k gaz ekliyor.
//cok bir fark. tek bir set -> 26k. (A'da bu 28k) 
contract A {

    B b;
    uint256 public balancee;
    
    function A() public payable {
        
    }
    
    function attachB( address _address) public {
        b = B(_address);
        b.attachA(address(this));
    }
    
    function setDataB(uint256 _data) public {
        b.setData(_data);
    }
 
    function getDataB() public view returns(uint256){
        return b.getData();
    }
    
    function setBalancee() public {
        balancee = address(this).balance;
    }
    
    function pay() public payable{
    }
    
    function () public payable {
        
    }
}

contract B {
    
    uint256 data;
    A a;
    function attachA( address _address) public {
        a = A(_address);
    }
    
    function getData() public view returns(uint256){
        return data;
    }
   
    function setData(uint256 _data) public {
        data = _data;
    }    
    
}