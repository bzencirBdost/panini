pragma solidity ^0.4.20;

import "browser/Card.sol";
import "browser/Album.sol";
import "browser/Utils.sol";
import "browser/Math.sol";
import "browser/FixedSupplyToken.sol";

contract Panini /* is FixedSupplyToken*/ {
    Card[] myCards;
    string[] public test;
     
    function Panini(
    
    ) public {
   
    }

    function length() public view returns(uint) {
         return test.length;        
    }

    function add(string val) public {
        test.push(val);        
    }

    function addIndex(uint index, string val) public {
        test[index] = val;
    }

    function removeIndex(uint index) public {
        require(index < test.length && index > 0 );
        delete test[index];
    }

    function print() public payable returns(string){
        string memory retVal = test[0]; // merak ettim noluyor bos ise?
        for (uint i = 1; i<test.length; i++) {
            string memory nextRetVal = strConcat(retVal , ",  " , test[i]);
            retVal = nextRetVal; 
        }
        return retVal;
    }
    
    function strConcatIn(string _a, string _b, string _c) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
    
        string memory ab = new string(_ba.length + _bb.length + _bc.length);
        bytes memory ba = bytes(ab);
    
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) ba[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) ba[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) ba[k++] = _bc[i];
        return string(ba);
    }

    function strConcat(string _a, string _b,string _c) internal returns (string) {
        return strConcat(_a, _b, _c);
    }
    
    function getMyCards() public view returns (Card []) {
        return myCards;
    }
    
}

