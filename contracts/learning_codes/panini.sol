
pragma solidity ^0.4.20;

//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
//not: yukaridaki token ozelliklerini kod icerisinde sagliyoruz. Bu yuzden basic gas verimi icin tercih edildi.
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol";

//randomize icin gerekli olacak.
//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

//Panini ERC721Token
contract PaniniERC721Token is ERC721BasicToken {
 
    // Token name
    string internal name_;
    
    // Token symbol
    string internal symbol_;

    function PaniniERC721Token() public {
        name_ = "Panini Token";
        symbol_ = "Panini Symbol";
    }
    
    function name() public view returns (string) {
        return name_;
    }
    
    function symbol() public view returns (string) {
        return symbol_;
    }
    
}

//this test failed.
//   msg.sender = paniniTokenTest.address
//   thus, in approve method, require(msg.sender == owner) returns false
//      owner: owner of token  
//we can use this pattern in market. (cryptoKitties uses for auctions.)
contract paniniTokenTest {
    //PaniniERC721Token nft;
    uint256 nextTokenId;
    
    function paniniTokenTest() public {
        //nft = new PaniniERC721Token();
    }
    
    function mint() public{
        nextTokenId = nextTokenId + 1;
      
        //nft.mint(msg.sender, nextTokenId);
    }
    
}
//true usage:
contract paniniTokenTest2 is PaniniERC721Token{
    uint256 nextTokenId;
    function mint() public{
        nextTokenId = nextTokenId + 1;
        super._mint(msg.sender, nextTokenId);
    }
 
}

//#########################################
//###    PANINI OWNERS - CONTROLLER     ###
//#########################################

contract PaniniOwner{
    address private owner;
    address public pendingOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function PaniniOwner() public {
        owner = msg.sender;
    }

    modifier __onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    function isOwner() view internal returns(bool res){
        if(msg.sender == owner) {
            res = true;
        }
    }

    modifier __onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    
    function transferOwnership(address newOwner) __onlyOwner public {
        pendingOwner = newOwner;
    }

    function claimOwnership() __onlyPendingOwner public {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

library Role {

    enum RoleType {
        CEO,
        CFO,
        COO
    }

    struct Data {
        RoleType roleType;
        bool active;
        string createdTime; //Date olabilir sonra
    }

}

contract UsingRole{
    using Role for Role.Data;

}


/**
 * The paniniDevAccount contract does this and that...
 */
contract PaniniDevAccounts is PaniniOwner, UsingRole {
    
    mapping(address => Role.Data) public devAccounts;

    event DevAccountRoleAdded(address _address);
    event DevAccountRoleRemoved(address _address);
    
    function PaniniDevAccounts() public {
        
    }    

    function addDevAccount(address _address, Role.RoleType _roleType, bool _active) __onlyOwner public returns(bool success) {
        if( devAccounts[_address].active == false ) {            
            devAccounts[_address].active = _active;
            devAccounts[_address].roleType = _roleType;
            devAccounts[_address].createdTime = "created Time";
            emit DevAccountRoleAdded(_address); //event'e role eklenebilir mi acaba?
            success = true;
        }
    }
    
    function removeDevAccount(address _address) __onlyOwner public returns(bool success) {
        if( devAccounts[_address].active == true ) {            
            devAccounts[_address].active = false;
            delete devAccounts[_address];
            emit DevAccountRoleRemoved(_address); //event'e role eklenebilir mi acaba?
            success = true;
        }
    }
   
    modifier __onlyCEO() {

        require(devAccounts[msg.sender].active == true);        
        require(devAccounts[msg.sender].roleType == Role.RoleType.CEO);
        _;
    }

    modifier __onlyCFO() {

        require(devAccounts[msg.sender].active == true);        
        require(devAccounts[msg.sender].roleType == Role.RoleType.CFO);
        _;
    }

    modifier __onlyCOO() {

        require(devAccounts[msg.sender].active == true);        
        require(devAccounts[msg.sender].roleType == Role.RoleType.COO);
        _;
    }

    /* err in usage.
    modifier __OnlyForThisRoles(bool _withOwner, Role.RoleType[] _roles) {
        bool result = false;
        if(_withOwner && isOwner()) {
            result = true;
        }
        if(devAccounts[msg.sender].active == true) {
            for(uint256 i = 0; i < _roles.length; i++) {
                if( devAccounts[msg.sender].roleType == _role[i]) {
                    result = true;                                
                }
            }
        }
        require (result == true);        
        _;
    }*/

    modifier __OnlyForThisRoles1(bool _withOwner, Role.RoleType _role1 ) {
        bool result = false;
        if(_withOwner && isOwner()) {
            result = true;
        }
        if(devAccounts[msg.sender].active == true && devAccounts[msg.sender].roleType == _role1 ) {
            result = true;            
        }
        require (result == true);        
        _;
    }

    modifier __OnlyForThisRoles2(bool _withOwner, Role.RoleType _role1, Role.RoleType _role2 ) {
        bool result = false;
        if(_withOwner && isOwner()) {
            result = true;
        }
        if(devAccounts[msg.sender].active == true) {
            if( devAccounts[msg.sender].roleType == _role1 
                || devAccounts[msg.sender].roleType == _role2) {
                result = true;            
            }
        }
        require (result == true);        
        _;
    }

    modifier __OnlyForThisRoles3(bool _withOwner, Role.RoleType _role1, Role.RoleType _role2, Role.RoleType _role3 ) {
        bool result = false;
        if(_withOwner && isOwner()) {
            result = true;
        }
        if(devAccounts[msg.sender].active == true) {
            if( devAccounts[msg.sender].roleType == _role1 
                || devAccounts[msg.sender].roleType == _role2                 
                || devAccounts[msg.sender].roleType == _role3) {
                result = true;            
            }
        }
        require (result == true);        
        _;
    }

}


library PaniniState {

    struct Data {
        bool paused;
    }

    function pause(PaniniState.Data self) pure internal {
        self.paused = true;
    }

    function unPause(PaniniState.Data self) pure internal {
        self.paused = false;
    }

}

contract UsingPaniniState{
    using PaniniState for PaniniState.Data;

}

contract PaniniController is PaniniDevAccounts, UsingPaniniState {
    event Pause();
    event Unpause();

    PaniniState.Data private paniniState;
    function PaniniController() public {
        //initial state.
        // starts with paused
        paniniState = PaniniState.Data(true);        
    }
    
    modifier __whenNotPaused() {
        require(!paniniState.paused);
        _;
    }

    modifier __whenPaused {
        require(paniniState.paused);
        _;
    }

    function pause() __OnlyForThisRoles1(true, Role.RoleType.CEO) public returns (bool success) {
        if(!paniniState.paused) {
            paniniState.pause();
            emit Pause();
            success = true;            
        }
    }

    function unPause() __OnlyForThisRoles1(true, Role.RoleType.CEO) public returns (bool success) {
        if(paniniState.paused) {
            paniniState.unPause();
            emit Unpause();
            success = true;
        }
    }
}



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

contract UsingCard is PaniniERC721Token{

    using AnimalCardBase for AnimalCardBase.Data;
    using AnimalCard for AnimalCard.Data;

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
    function existAnimalCardBase(uint256 _baseId ) public view returns(bool) {
        if( _baseId > 0 && _baseId <= animalCardBase.length) {
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
    
    function exists(uint256 _cardId) public view returns (bool) {
        return super.exists(_cardId);
    }

    function ownerOf(uint256 _cardId ) public view returns(address) {
        return super.ownerOf(_cardId);
    }
    //cart üretilmesi için.
    //token kullanacak.
    //to: token icin. 
    //baseId: random generated value of basecard index. 
    function mintCardWithBaseId(address _to, uint256 _baseId) internal returns(uint256){

        uint256 tokenId = animalCards.length;
        super._mint(_to, tokenId);
        // set baseId of metedata
        AnimalCard.Data memory animalCard = AnimalCard.Data(_baseId, tokenId, 0);        
        animalCards.push(animalCard); 
        tokensOfEachCards[_baseId].push(tokenId);
        return tokenId;
    }
    
    function getAnimalCardBase(uint256 _baseId) internal view returns(AnimalCardBase.Data) {
        return animalCardBase[_baseId].clone();
    }
            
}

//#########################################
//###             GAMECORE              ###
//#########################################

library GameCore {

    struct Data {
  
    }
  
}

contract UsingGameCore is UsingCard, PaniniController {
    using GameCore for GameCore.Data;

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
        //cardId -> index of animalCards[baseId]
        mapping(uint256 => uint256) animalCardsIndex;    
    }
    
    function hasCard(Data storage self, uint256 _baseId ) public view returns(bool) {
        if(self.animalCards[_baseId].length == 0) {
            return false;
        }
        return true;                
    }
    

    function addCard(Data storage self, uint256 _baseId, uint256 _cardId) internal {
        uint256 cardId = _cardId;
        self.animalCardsIndex[cardId] = self.animalCards[_baseId].length;
        self.animalCards[_baseId].push(cardId); 
    }

    function removeCard(Data storage self, uint256 _baseId, uint256 _cardId) internal {
        if(hasCard(self, _baseId)) {        
            uint256 cardIndex = self.animalCardsIndex[_cardId];
            //TODO CONTROL lValue is not (0 -1)
            uint256 lastCardIndex = self.animalCards[_baseId].length - 1;
            uint256 lastCard = self.animalCards[_baseId][lastCardIndex];

            self.animalCards[_baseId][cardIndex] = lastCard;
            self.animalCards[_baseId][lastCardIndex] = 0;

            self.animalCards[_baseId].length--;
            self.animalCardsIndex[_cardId] = 0;
            self.animalCardsIndex[lastCard] = cardIndex;

        }
    }
    
}

contract UsingPlayer is UsingGameCore{
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
  
    function addRandomCardToPlayer(address _address) internal {
        isPlayer(_address);
        uint256 baseId = generateRandomCardId(players[_address].number_of_stars);
        //kart'in üretilmesi.
        uint256 tokenId = mintCardWithBaseId(_address, baseId);
        players[_address].addCard(baseId, tokenId);
        animalCards[tokenId].ownerId = players[_address].id;        
        players[_address].number_of_stars = players[_address].number_of_stars + 1; // simdilik kart sayisi olsun. 
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return super.balanceOf(_owner);
    }

    function approve(address _to, uint256 _cardId) public {
        super.approve(_to, _cardId);
    }

    function getApproved(uint256 _cardId) public view returns (address) {
        return super.getApproved(_cardId);
    }

    //TO DO: bazi metodlar disari kapanacak. Bunun disaridan kullanilmasini istemiyoruz mesela.
    function transferFrom(address _from, address _to, uint256 _cardId) public {
        super.transferFrom(_from, _to, _cardId);
    }        

    function safeTransferFrom(address _from, address _to, uint256 _cardId) public {
        safeTransferFrom(_from, _to, _cardId, "");        
    }

    function safeTransferFrom(address _from, address _to, uint256 _cardId, bytes _data) public {
        super.safeTransferFrom(_from, _to, _cardId, _data);
        //cart sahibini degistir.
        animalCards[_cardId].ownerId = players[_to].id;
        //buradaki tasima islemleri.
        // remove card from previous player
        // add card to other player
        uint256 baseId = animalCards[_cardId].baseId;
        uint256 cardId = _cardId;
        players[_from].removeCard(baseId, cardId);
        players[_to].addCard(baseId, cardId);
        
    }


    // name and sayisi
    function getMyCard(uint256 _cardId) __isPlayer public view returns(string, uint256, string) {
        uint256 count = 0;
        string memory name = "";        
        string memory err = "";        
        //kart var mı yani token var mi? : token yok ise baseId = 0 gelecektir.
        uint256 baseId = animalCards[_cardId].baseId;
        if (existAnimalCardBase(baseId)) {
            name = animalCardBase[baseId].name;                    
            //cont = players[msg.sender].hasCard(baseId);
            //kartin sahibi mi?
            if( players[msg.sender].id == animalCards[_cardId].ownerId) {
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

