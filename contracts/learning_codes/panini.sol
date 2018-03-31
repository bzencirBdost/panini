
pragma solidity ^0.4.20;

//randomize icin gerekli olacak.
//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

//#########################################
//###               CARDS               ###
//#########################################

library AnimalCardBase {
    
    enum Region {
        ASIA,
        AFRICA,
        NOURTH_AMERICA,
        SOUTH_AMERICA,
        ANTARCTICA,
        EUROPE,
        AUSTRALIA,
        OCEAN
    }
   
    //data
    struct Data {
        
        //kullanilmayacak, bunun yerine indexler id olacak.
        uint256 id; // arr index: 0: empty initialized and never used.
        string name;
        uint256 health; //life expectancy
        uint256 weigth; //str
        uint256 speed; //dex
        Region region;
        uint256 rarity; // 0-100 arasinda bir sayi. 
    }
    
    //returns clone of base card.
    function clone(AnimalCardBase.Data self) internal pure returns(AnimalCardBase.Data) {
        return AnimalCardBase.Data(self.id, self.name, self.health, self.weigth, self.speed, self.region, self.rarity);
    }


}


//kartlara ozel bazi farkliliklar katilabilir? 
//Mesela ayni tip kart'in ozellikleri random degisebilir %5 gibi?
//price burada tutulabilir bu durumda vs.
library AnimalCard {
    
    //data
    struct Data {
        
        uint256 baseId; // arr index: 0: empty initialized and never used.
        uint256 tokenId; 
        uint256 ownerId; //playerId
    }
}

contract UsingCard {

    using AnimalCardBase for AnimalCardBase.Data;
    using AnimalCard for AnimalCard.Data;

    //TO DO: NFT nft; //eklenecek. bunun metodlari iceride kullanilacak.

    // metedata
    AnimalCardBase.Data[] animalCardBase; 

    // created cards: metedata ile token'i bagliyor.
    //Normal token listesinden farki.
    //
    //tokenid(index = tokenId) -> baseid, + tokenid (app'da ise yarayabilir.)
    AnimalCard.Data[] animalCards; 
    //farkli kart tipleri icin uretilen tokenlar
    // baseId -> tokenId list -> index of animalCards 
    mapping(uint256 => uint256[]) tokensOfEachCards;

    //for test
    uint256 random;
    
    function UsingCard() public {
        random = 1;
        initAnimalCardBase();
        AnimalCard.Data memory emptyAnimalCard = AnimalCard.Data(0, 0, 0);        
        animalCards.push(emptyAnimalCard);

    }
    
    function initAnimalCardBase() internal {
        //id'lerin indexler ile ayni olmasi icin eklendi. Kullanilmayacak. bunun id'si 0.
        createAnimalCardBase('empty', 0, 0, 0, AnimalCardBase.Region.AFRICA, 0 );        
        
        createAnimalCardBase('fil', 1000, 3000, 60, AnimalCardBase.Region.AFRICA, 14 );        
        createAnimalCardBase('at', 400, 500, 90, AnimalCardBase.Region.ASIA, 22 );        
        createAnimalCardBase('tavsan', 20, 2, 80, AnimalCardBase.Region.EUROPE, 55 );        
        createAnimalCardBase('aslan', 200, 200, 80, AnimalCardBase.Region.AFRICA, 21 );        

        createAnimalCardBase('balina', 10000, 30000, 40, AnimalCardBase.Region.OCEAN, 14 );        
        createAnimalCardBase('yunus', 1000, 300, 80, AnimalCardBase.Region.OCEAN, 25 );        
        createAnimalCardBase('kilic baligi', 100, 40, 140, AnimalCardBase.Region.OCEAN, 5 );        

        createAnimalCardBase('kartal', 100, 15, 100, AnimalCardBase.Region.ASIA, 25 );        
        createAnimalCardBase('guvercin', 10, 1, 30, AnimalCardBase.Region.SOUTH_AMERICA, 24 );        

        createAnimalCardBase('karinca', 1, 1, 1, AnimalCardBase.Region.EUROPE, 43 );        

    }
    
    // usuable id between 1 to (n-1)
    function existAnimalCardBase(uint256 id ) public view returns(bool) {
        if( id > 0 && id <= animalCardBase.length) {
            return true;
        }
        return false;                
    }

    //usuable card id starts with 1.
    function createAnimalCardBase(string _name, uint256 _health, uint256 _weigth, uint256 _speed, AnimalCardBase.Region _region, uint256 _rarity ) internal{
        uint256 id = animalCardBase.length;
        animalCardBase.push(AnimalCardBase.Data(id, _name, _health, _weigth, _speed, _region, _rarity));
    }
    
    //returns index of animalCardBase
    function generateRandomCardId(uint256 _number_of_stars) internal view returns (uint256) {
        //private test for random
        uint256 id = random;
        uint256 extra = _number_of_stars + 2;
        uint256 delta = animalCardBase.length -1;
        require(delta > 0);

        id =( ( ( id + 2 ) * ( 3 * id + 2 ) + extra ) % delta ) + 1;

        return id;

        // random'u nasil yapacagiz buna karar verilecek.
        //kartlar eklenirken bir islem yapilacak. random card genereate ederken secim buna gore. bir array'den index cikartilacak.
    }
    
    //cart üretilmesi için.
    //token kullanacak.
    //to: token icin. 
    //baseId: random generated value of basecard index. 
    function mintCardWithId(address _to, uint256 baseId) internal returns(uint256){

        uint256 tokenId = animalCards.length;
        //to do: add erc721 mint. (_to, id);
        // set baseId of metedata
        AnimalCard.Data memory animalCard = AnimalCard.Data(baseId, tokenId, 0);        
        animalCards.push(animalCard); 
        tokensOfEachCards[baseId].push(tokenId);
        return tokenId;
    }
    
    function getAnimalCardBase(uint256 id) internal view returns(AnimalCardBase.Data) {
        return animalCardBase[id].clone();
    }
            
}


//#########################################
//###            PLAYERS                ###
//#########################################
library Player {

    struct Data {
        uint256 id; // adress olabilir, yada id kalsın. bakarız.
        string name;
        uint256 number_of_stars;
        //baseId -> cardIndex-tokenId
        mapping(uint256 => uint256[]) animalCards;    
    }
    
    function hasCard(Data storage self, uint256 id ) public view returns(bool) {
        if(self.animalCards[id].length == 0) {
            return false;
        }
        return true;                
    }
    
}

contract UsingPlayer is UsingCard{
    using Player for Player.Data;
    mapping (address => Player.Data) players;
    mapping (uint256 => address) playerIdToAddress;
    
    uint256 number_of_player;
    
    function UsingPlayer() public {
        number_of_player = 0;
    }
    
    modifier __isPlayer {
        require(players[msg.sender].id != 0);
        _;
    }

    function isPlayer(address _address) internal view{
        require(players[_address].id != 0);
    }
    
    function addRandomCardToPlayer(address _address) internal {
        isPlayer(_address);
        uint256 baseId = generateRandomCardId(players[_address].number_of_stars);
        //kart'in üretilmesi.
        uint256 tokenId = mintCardWithId(_address, baseId);
        players[_address].animalCards[baseId].push(tokenId);
        animalCards[tokenId].ownerId = players[_address].id;        
        players[_address].number_of_stars = players[_address].number_of_stars + 1; // simdilik kart sayisi olsun. 
    }
    
    function register(string _name) public {
        require(players[msg.sender].id == 0);
        number_of_player = number_of_player + 1;
        players[msg.sender].id = number_of_player; 
        players[msg.sender].name = _name;
        //5x card 
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
        addRandomCardToPlayer(msg.sender);
    }    
    
    function getPlayerName() __isPlayer public view returns(string) {
        return players[msg.sender].name;
    }
  
    // name and sayisi
    function getMyCard(uint256 tokenId) __isPlayer public view returns(string, uint256, string) {
        uint256 count = 0;
        string memory name = "";        
        string memory err = "";        
        //kart var mı yani token var mi? : token yok ise baseId = 0 gelecektir.
        uint256 baseId = animalCards[tokenId].baseId;
        if (existAnimalCardBase(baseId)) {
            name = animalCardBase[baseId].name;                    
            //cont = players[msg.sender].hasCard(baseId);
            //kartin sahibi mi?
            if( players[msg.sender].id == animalCards[tokenId].ownerId) {
                count = players[msg.sender].animalCards[baseId].length;           

            } else {
                //TO DO: get message from struct of messages.
                err = "You are not owner of this card."; 
            }
        } else {
            //TO DO: get message from struct of messages.
                err = "There is not card with this id."; 
        }

        return (name, count, err);        
    }

    function getMyAllCardIds() __isPlayer public view returns(uint256[]) {
        
        uint256[] memory cards = new uint256[](animalCardBase.length);
        for(uint256 i = 1; i < animalCardBase.length; i++) {
            cards[i] = players[msg.sender].animalCards[i].length;
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

