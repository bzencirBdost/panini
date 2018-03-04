pragma solidity ^0.4.20;

import "general/fixed_supply_token.sol";

contract PaniniToken is FixedSupplyToken {

    function PaniniToken() FixedSupplyToken("bdostToken" , "bdost") public {}
}

