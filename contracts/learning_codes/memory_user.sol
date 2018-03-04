pragma solidity ^0.4.20;
import "browser/Token.sol";

contract MemoryUser is TokenContractFragment {

    mapping (address => User) public users;

    //event Transfer(address indexed _from, address indexed _to, uint256 _value);
    struct User {
        address adr;
        uint balance;
        uint procCount;
    }

    function findSender() internal view returns( User ) {
        return users[msg.sender];
    }

    function MemoryUser() public {
        users[tx.origin].adr = tx.origin;
        users[tx.origin].balance = 1000;
        users[tx.origin].procCount = 0;
    }

    function incProcCount(User user) pure internal {
        user.procCount++;        
    }

    function sendCoin(address to, uint amount) public payable returns(bool sufficient) {
        User memory sender = findSender();
        User memory receiver = users[to];
        incProcCount(sender);
        if (sender.balance < amount) return false;

        sender.balance -= amount;
        receiver.balance += amount;
        
        users[msg.sender] = sender;
        users[to] = receiver;
        
        //Transfer(msg.sender, receiver, amount);
        return true;
    }

    function getBalance(address addr) public view returns(uint) {
        return users[addr].balance;
    }
    
    function getProcCount(address addr) public view returns(uint) {
        return users[addr].procCount;
    }
}
