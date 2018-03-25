pragma solidity ^0.4.18;

import "/general/owned.sol";

contract Mortal is Owned {
    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }
}
