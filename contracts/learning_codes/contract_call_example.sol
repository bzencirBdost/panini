pragma solidity ^0.4.11;
//link: https://blog.colony.io/writing-upgradeable-contracts-in-solidity-6743f0eecc88

contract Service{

  function isAlive() public constant returns(bool alive) {
    // do something
    return true;
  }
}


contract Service{
  function isAlive() constant returns(bool alive) {} // empty because we're not concerned with internal details
}

contract Client {
  Service _s; // "Service" is a Type and the compiler can "see" it because this is one file. 

  function Client(address serviceAddress) {
    _s = Service(serviceAddress); // _s will be the "Service" located at serviceAddress
  }

  function Ping() public constant returns(bool response) {
    return _s.isAlive(); // message/response to Service is intuitive
  } 
}