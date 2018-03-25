pragma solidity ^0.4.20;

import "general/owned/mortal.sol";
import "panini/panini_token.sol";

contract Panini is PaniniToken, Mortal {
    
    function Panini() public {

    } 
}


pragma solidity ^0.4.20;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

//#########################################
//###               CARDS               ###
//#########################################
library AnimalCard {
    
    enum Geography {
        ASIA,
        AFRICA,
        NOURTH_AMERICA,
        SOUTH_AMERICA,
        ANTARCTICA,
        EUROPE,
        AUSTRALIA,
        OCEAN
    }
    
    enum Element {
        EARTH, // kara hayvanlari
        WATER, // water creatures
        AIR, // birds
        FIRE // insect
    }
    
    struct Data {
        uint id; //not: id = arr index + 1 , ipfs icin gerekli.
        string name;
        uint health; //life expectancy
        uint weigth; //str
        uint speed; //dex
        Geography geography;
        Element element; // family
        uint rarity; // 0-100 arasinda bir sayi. 
    }
    
}


contract UsingCard {
    using AnimalCard for AnimalCard.Data;
    AnimalCard.Data[] animalCards;
    mapping(uint => uint) numberOfAnimalCardCreated;
    uint random;
    
    function UsingCard() public {
        random = 1;
        initAnimalCards();
    }
    
    function initAnimalCards() internal {
        addAnimalCard('fil', 1000, 3000, 60, AnimalCard.Geography.AFRICA, AnimalCard.Element.EARTH, 14 );        
        addAnimalCard('at', 400, 500, 90, AnimalCard.Geography.ASIA, AnimalCard.Element.EARTH, 22 );        
        addAnimalCard('tavsan', 20, 2, 80, AnimalCard.Geography.EUROPE, AnimalCard.Element.EARTH, 55 );        
        addAnimalCard('aslan', 200, 200, 80, AnimalCard.Geography.AFRICA, AnimalCard.Element.EARTH, 21 );        

        addAnimalCard('balina', 10000, 30000, 40, AnimalCard.Geography.OCEAN, AnimalCard.Element.WATER, 14 );        
        addAnimalCard('yunus', 1000, 300, 80, AnimalCard.Geography.OCEAN, AnimalCard.Element.WATER, 25 );        
        addAnimalCard('kilic baligi', 100, 40, 140, AnimalCard.Geography.OCEAN, AnimalCard.Element.WATER, 5 );        

        addAnimalCard('kartal', 100, 15, 100, AnimalCard.Geography.ASIA, AnimalCard.Element.AIR, 25 );        
        addAnimalCard('guvercin', 10, 1, 30, AnimalCard.Geography.SOUTH_AMERICA, AnimalCard.Element.AIR, 24 );        

        addAnimalCard('karinca', 1, 1, 1, AnimalCard.Geography.EUROPE, AnimalCard.Element.FIRE, 43 );        

    }
    
    function isExistAnimalCard(uint index ) public view returns(bool) {
        if(animalCards.length <= index) {
            return false;
        }
        return true;                
    }

    function addAnimalCard(string _name, uint _health, uint _weigth, uint _speed, AnimalCard.Geography _geography, AnimalCard.Element _element, uint _rarity ) internal{
        uint id = animalCards.length + 1;
        animalCards.push(AnimalCard.Data(id, _name, _health, _weigth, _speed, _geography, _element, _rarity));
    }
    
    function generateRandomCardId(uint _number_of_stars) internal returns (uint) {
        //private test for random
        uint id = random;
        uint extra = _number_of_stars + 2;
        uint delta = animalCards.length;
        require(delta > 0);

        id = (id + 2) * (3*id + 2) * extra;
        while( id >= delta) { // id min 0 olmali
            id = id - delta;
        }
        numberOfAnimalCardCreated[id] = numberOfAnimalCardCreated[id] + 1;
        random = id;
        return id;

        // random'u nasil yapacagiz buna karar verilecek.
        //kartlar eklenirken bir islem yapilacak. random card genereate ederken secim buna gore. bir array'den index cikartilacak.
    }
    
    function getCardFromId(uint id) internal view returns (AnimalCard.Data) {
        AnimalCard.Data memory card = animalCards[id];
        return AnimalCard.Data(card.id, card.name, card.health, card.weigth, card.speed, card.geography, card.element, card.rarity);
    }
}


//#########################################
//###            PLAYERS                ###
//#########################################
library Player {
    struct Data {
        uint id;
        string name;
        uint number_of_stars;
        mapping(uint => uint) animalCards;
    }
    
    function hasCard(Data storage self, uint index ) public view returns(bool) {
        if(self.animalCards[index] == 0) {
            return false;
        }
        return true;                
    }
    
}

contract UsingPlayer is UsingCard{
    using Player for Player.Data;
    mapping (address => Player.Data) players;
    uint number_of_player;
    
    function UsingPlayer() public {
        number_of_player = 0;
    }
    
    modifier __isPlayer {
        require(players[msg.sender].id != 0);
        _;
    }
    
    modifier __isNotPlayer {
        require(players[msg.sender].id == 0);
        _;
    }
    function isPlayer(address _address) internal view{
        require(players[_address].id != 0);
    }
    
    function addRandomCardToPlayer(address _address) internal {
        isPlayer(_address);
        uint card_index = generateRandomCardId(players[_address].number_of_stars);
        players[_address].animalCards[card_index] = players[_address].animalCards[card_index] + 1;
        players[_address].number_of_stars = players[_address].number_of_stars + 1; // simdilik kart sayisi olsun. 
    }
    
    function register(string _name) public __isNotPlayer{
        number_of_player = number_of_player +1;
        players[msg.sender].id = number_of_player;
        players[msg.sender].name = _name;
        //5x card 
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
    }    
    
    function getPlayerName() public view returns(string) {
        return players[msg.sender].name;
    }
  
    // name and sayisi
    function getMyCard(uint index) __isPlayer public view returns(string, uint) {
        uint count = 0;
        string memory name = "Err";
        
        bool cont = isExistAnimalCard(index);
        if (cont) {
            name = animalCards[index].name;                    
            cont = cont && players[msg.sender].hasCard(index);
        } else {
            //throw err
        }

        if(cont ) {
            count = players[msg.sender].animalCards[index];           
        }
        
        return (name, count);        
    }

    function getMyAllCardIds() __isPlayer public view returns(uint[]) {
        
        uint[] memory cards = new uint[](animalCards.length);
        for(uint i = 0; i < animalCards.length; i++) {
            if(players[msg.sender].hasCard(i)) {
                cards[i] = players[msg.sender].animalCards[i];
            }
        }
        return cards;
    }
}

//#########################################
//###             PANINI                ###
//#########################################
contract Panini is UsingPlayer{

    function Panini() public {
    
        
    }
    
    function addPackageToPlayerTest(address _address) public payable {
        addRandomCardToPlayer(_address);
        addRandomCardToPlayer(_address);
        addRandomCardToPlayer(_address);
        addRandomCardToPlayer(_address);
        addRandomCardToPlayer(_address);
    }

}

