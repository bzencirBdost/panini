pragma solidity ^0.4.21;

contract A {
    
    bool public vara = true;

}

contract B {
    A a;
    function setA(address _address) public {
        A aa = A(_address);
        if(aa.vara()) {
            a = aa;
        }
    }
}
