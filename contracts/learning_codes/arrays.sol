pragma solidity ^0.4.20;

contract Arrays2 {
    
    string name;
    Arrays next;
    function Arrays2(string _name) public {
        name = _name;
    }
    
    
    function addC(string _name) public{
        next = new Arrays(_name); //error'e sebep veriyor. ilginc.
    }
    

}

contract Arrays {
    

    string name;
    uint[] x;
    Arrays2 next;
    
    
    function Arrays(string _name) public {
        name = _name;
        x = new uint[](10);
    }
    
    function addC(string _name) public{
        next = new Arrays2(_name);
    }
    
    function addX(uint k) public {
        x.push(k);
    }

    function dellastX() public {
        uint len = x.length;
        delete x[len-1];
    }

    function dellastXX() public {
        uint len = x.length;
        uint[] memory x2 = new uint[](len-1);
        
        for(uint i = 0; i < len-1; i++) {
            x2[i] = x[i];
        }
        delete x;
        x = x2;
    }

    function addnX(uint n, uint k) public {
        x[n] = k;
    }
     
    function getX() public view returns(uint[]){
        return x;
    }   
    
    function setName(string k) public {
        name = k;
    }
     
    function getName() public view returns(string){
        return name;
    }   
    
}



pragma solidity ^0.4.20;

//#########################################
//###               CARDS               ###
//#########################################
library CardLib {
    
}

contract UsingCards { 
    using CardLib for Card;
    
    struct Card {
        uint id;
        string name;
        
    }
    
    function createRamdomCards() pure internal returns(Card[]) {
        Card[] memory cards;
        cards[cards.length] = Card(1, "Jaguar");
        cards[cards.length] = Card(2, "Lion");
        cards[cards.length] = Card(3, "Tiger");
        cards[cards.length] = Card(4, "leopard");
        cards[cards.length] = Card(5, "cheetah");
        return cards;        
    }
}



//#########################################
//###            PLAYERS                ###
//#########################################
library PlayerLib {

}
contract UsingPlayer is UsingCards{ 
    using PlayerLib for Player;
    
        struct Player {
        string name;
        uint number_of_stars;
        Card[] cards;
    }
    
    function createPlayer(string _name) pure internal returns(Player){
        Card[] memory cards = createRamdomCards();
        return Player(_name, cards.length, cards);

    }

}

//#########################################
//###             PANINI                ###
//#########################################
contract Panini is UsingPlayer {
    
    mapping (address => Player) players;
    
    function Panini() public {
    
        
    }

    function register(string _name) public {
        Player storage newPlayer = createPlayer(_name);
        players[msg.sender] = newPlayer;
    }    
    
}


pragma solidity ^0.4.20;

//#########################################
//###               CARDS               ###
//#########################################
library CardLib {
    
}

contract UsingCards { 
    using CardLib for Card;
    
    struct Card {
        uint id;
        string name;
        
    }
}


contract CardManager is UsingCards{
    
    function CardManager() public {
    
    }
    
    function createRamdomCards() pure internal returns(Card[]) {
        Card[] memory cards;
        cards[cards.length] = Card(1, "Jaguar");
        cards[cards.length] = Card(2, "Lion");
        cards[cards.length] = Card(3, "Tiger");
        cards[cards.length] = Card(4, "leopard");
        cards[cards.length] = Card(5, "cheetah");
        return cards;        
    }
}

//#########################################
//###            PLAYERS                ###
//#########################################
library PlayerLib {

}
contract UsingPlayer is UsingCards{ 
    using PlayerLib for Player;
    
        struct Player {
        string name;
        uint number_of_stars;
        Card[] cards;
    }
}


contract PlayerManager is UsingPlayer {
    
    CardManager cm;

    mapping(address => Player) public players;

    function PlayerManager() public {
        cm = new CardManager();

    }
    
    function createPlayer(string _name) pure internal returns(Player){
        Card[] memory cards = cm.createRamdomCards();
        return Player(_name, cards.length, cards);

    }
    
}


//#########################################
//###             PANINI                ###
//#########################################
contract Panini is UsingPlayer{
    
    PlayerManager pm;
    CardManager cm;
    
    mapping (address => Player) players;
    
    function Panini() public {
        pm = new PlayerManager();
        cm = new CardManager();
    }

}
