pragma solidity ^0.4.20;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

 

contract RandomTest is usingOraclize {

  uint256 public randomInt;
  event onCallback(string result);
    address owner;
  function RandomTest() public {
    oraclize_setNetwork(networkID_consensys);
    owner = msg.sender;
  }

  function __callback(bytes32 myid, string result) {
    onCallback(result);
    if (msg.sender != oraclize_cbAddress()) throw;
    randomInt = parseInt(result);
  }

  function update() public payable{
  oraclize_query("URL", "json(https://api.random.org/json-rpc/1/invoke).result.random.data.0", '\n{"jsonrpc":"2.0","method":"generateIntegers","params":{"apiKey":"1f50e952-c1cd-4edc-8944-96f5fd382542","n":1,"min":1,"max":10,"replacement":true,"base":10},"id":1}'); 
  }
  
    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }
}