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

    modifier __onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function isOwner() view internal returns(bool res){
        if(msg.sender == owner) {
            res = true;
        }
    }

    function transferOwnership(address newOwner) __onlyOwner public {
        pendingOwner = newOwner;
    }

    function claimOwnership() __onlyPendingOwner public {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    function kill() public{
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
 * The paniniDevAccounts contract does this and that...
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
        uint256 presaledEndDate;
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
    PaniniState.Data paniniState;

}

contract Mutex {
    mapping (address => bool) mutex;
    
    function enter() public view {
        if ( mutex[msg.sender] == true) { throw; }
        mutex[msg.sender] == true;
    }

    function left() public {
        //false yapmak da yeterli mi?
        delete mutex[msg.sender];
    }
    
}


//#########################################
//###           SHAREHOLDER             ###
//#########################################


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
    mapping (address => Shareholder.Data) shareholderData;
    address[] shareholders;
    mapping (address => uint256) shareHoldersIndex;
    mapping (address => address) ownerToPendingShareholders;
    mapping (address => address) pendingShareholdersToOwner;

    event ShareholderOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    uint256 totalPercentage;
    uint256 ownerBalance;

    //for security
    Mutex mutex;

    modifier __isOnlyOwnerOfShareholder() {
        require(shareholderData[msg.sender].owner != msg.sender);
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

    function isShareHolder(address _address) public view returns(bool) {
        if(shareholderData[_address].owner != _address) {
            return true;
        }
        return false;
    }

    function addShareHolder(address _address, uint256 _percentage) internal {
        
        require (isShareHolder(_address) == false);

        uint nextTotalPercentage = totalPercentage + _percentage;
        if(nextTotalPercentage <= 100) {
            shareholderData[_address] = Shareholder.Data(_address, _percentage, 0);
            shareHoldersIndex[_address] = shareholders.length;
            shareholders.push(_address);
            totalPercentage = nextTotalPercentage;
        }                            
    }   
    
    //distributeBalance
    function distributeBalance(uint256 _amount) internal{
        if(_amount != 0) {

            uint256 amount = _amount;
            uint256 onePercentOfAmount = amount / 100;
            
            for(uint256 i = 0; i < shareholders.length; i++) {
                address shareholder = shareholders[i];
                uint percentage = shareholderData[shareholder].percentage;
                uint addBalance = percentage * onePercentOfAmount;
                
                shareholderData[shareholder].balance += addBalance;
                amount -= addBalance;
            }        

            //note: hic bir zaman total percentage 100'u gecmeyecegi icin,
            // amount for dongusu sonunda pozitif olacaktir.
            // kontrolu addShareHolder'da yapilmisti.
            ownerBalance += amount;
        }                
    }
    
    function withdrawShareholderBalance() __isOnlyOwnerOfShareholder public payable {
        mutex.enter();
        uint256 balance = shareholderData[msg.sender].balance;
        shareholderData[msg.sender].balance = 0;
        if(!msg.sender.call.value(balance)()) { throw;}
        emit WithdrawShareholderBalance(msg.sender, balance);
        mutex.left();        
    }
    
    //TODO: bunun cagrildigi yer payable olmali.
    function withdrawOwnerBalance() internal {
        mutex.enter();
        uint256 balance = ownerBalance;
        ownerBalance = 0;
        if(!msg.sender.call.value(balance)()) { throw;}
        emit WithdrawOwnerBalance(msg.sender, balance);
        mutex.left();        
    }

    function transferShareholderOwnership(address _newOwner) __isOnlyOwnerOfShareholder public {        
        require (msg.sender != _newOwner);  
        ownerToPendingShareholders[msg.sender] = _newOwner;
        pendingShareholdersToOwner[_newOwner] = msg.sender;
    }

    function claimShareholderOwnership() public {

        address owner = pendingShareholdersToOwner[msg.sender];
        address pendingOwner = ownerToPendingShareholders[owner];

        if(pendingOwner == msg.sender && pendingOwner != address(0)) {
            //delete all data about pending owner
            delete pendingShareholdersToOwner[msg.sender];
            delete ownerToPendingShareholders[owner];       

            //pendingOwner is has another acc.
            if(isShareHolder(pendingOwner)) {
                //balance add.
                //percentage add.
                shareholderData[pendingOwner].balance += shareholderData[owner].balance;               
                shareholderData[pendingOwner].percentage += shareholderData[owner].percentage;

                //delete old acc.
                uint256 index = shareHoldersIndex[owner];
                uint256 lastIndex = shareholders.length - 1; //bu scope'ta her zaman > 0                
                address lastAddress = shareholders[lastIndex];

                shareholders[index] = lastAddress;
                shareholders[lastIndex] = address(0);
                shareholders.length--;

                shareHoldersIndex[owner] = 0;
                shareHoldersIndex[lastAddress] = index;
            } else {
                //owner vs degistir.
                shareholderData[pendingOwner].owner = pendingOwner;
                shareholderData[pendingOwner].balance = shareholderData[owner].balance;               
                shareholderData[pendingOwner].percentage = shareholderData[owner].percentage;

                index = shareHoldersIndex[owner];
                shareholders[index] = pendingOwner;
            }
            
            delete shareholderData[owner];

            emit ShareholderOwnershipTransferred(owner, pendingOwner);
        }
    }


    function () public payable {
        
    }
    
}


contract PaniniController is PaniniDevAccounts, UsingPaniniState, UsingShareholder {
    event Pause();
    event UnPause();
    event Presaled();
    event UnPresaled();

    function PaniniController() public {
        //initial state.
        // starts with paused
        //3. parametre degistirilecek. tarih girilecek sonra.  
        paniniState = PaniniState.Data(true, true, 1231512);       
        mutex = new Mutex();
    }
    
    modifier __whenNotPaused() {
        require(!paniniState.paused);
        _;
    }

    modifier __whenPaused() {
        require(paniniState.paused);
        _;
    }

    modifier __whenNotPresaled() {
        require(!paniniState.presaled);
        _;
    }

    modifier __whenPresaled() {
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
            emit UnPresaled();
            success = true;
        }
    }

    function withdrawBalance() __OnlyForThisRoles1(true, Role.RoleType.CFO) public payable {
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
        address owner; 
    }
}

contract UsingCard is PaniniERC721Token, PaniniController {

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


//#########################################
//###              PACKAGE              ###
//#########################################


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

    function packageExists(uint256 _packageId) public view returns(bool) {        
        if(createdPackages[_packageId].id != 0) {
            return true;
        }
        return false;
    }

    function isOwnerOfPackage(uint256 _packageId) public view returns(bool isOwner) {
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
    function computePriceOfPackage(uint _numberOfPackage) public view returns(uint256 price) {
         //initial price
        if(numberOfPackageCreated <= 100 && now < paniniState.presaledEndDate) {
            uint remaining = 100 - numberOfPackageCreated;
            //to do: sadece presale icin olacak.
            if(_numberOfPackage < remaining ) {
                //TO DO: check owerflow?
                price = _numberOfPackage * prices.initial;
            } else {
                price = (remaining * prices.initial) + ((_numberOfPackage - remaining) * prices.normal);
            } 

        //normal price
        } else {
            price = _numberOfPackage * prices.normal;
        }
        //TO DO: ozel gun ise fiyat belirle
        //else if .. {}

        
    }
    
}


//#########################################
//###              MARKET               ###
//#########################################

library Auction {

    struct Data {
        address owner;
        uint256 cardId;
        uint256 createdTime;
        uint256 startPrice;
        uint256 endPrice;
        uint256 duration; 

    }
  
}


contract PaniniMarket {
    using Auction for Auction.Data;

    // Reference to contract tracking NFT ownership
    PaniniERC721Token public nft; // panini
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    function PaniniMarket(address _nftAddress, uint256 _cut) public {
        //TODO: control address + msg.sender
        nft = PaniniERC721Token(_nftAddress);
        ownerCut = _cut;
    }
    
    function getOwnerCut() public view returns(uint256) {
        return ownerCut;
    }

}

//TODO: bu contract'a balance yuklenmeli.
contract UsingPaniniMarket is UsingCardPackage{
    using Auction for Auction.Data;

    event CreateAuction(address owner, uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration);
    event CancelAuction(address owner, uint256 _cardId);
    event Bid(address owner, address sender, uint256 _cardId, uint256 currentPrice, uint256 cutof);
    
    //cardId -> Auction
    mapping (uint256 => Auction.Data) auctions;

    //butun auctionlari listelemek icin.
    uint256[] auctionCardIds; 
    //cardId -> auctionCardIds index    
    mapping (uint256 => uint256) auctionCardIdsIndex;

    //bir kisiye ait auctionlari listelemek icin
    //address -> cardId list
    mapping (address => uint256[]) ownerOfAuctionCardIds; // bir kisiye ait auctionlari listesi
    //cardId -> ownerOfAuctionCardIds index
    mapping (uint256 => uint256) ownerOfAuctionCardIdsIndex; // bu kartin bu listedeki yeri.
    

    PaniniMarket market;

    //TODO: control address + msg.sender
    // bir kere set edilmeli? daha sonradan degistirilememeli?
    function setMarket(address _marketAddress) public {
        market = PaniniMarket(_marketAddress);
    }

    function getAddress() public view returns(address) {
        require(address(market) != address(0));        
        return address(market);
    }

    function getOwnerOfAuctionFromCardId(uint256 _cardId) public view returns(address) {
        require (auctions[_cardId].cardId == 0 && _cardId != 0);
        return auctions[_cardId].owner;
    }


    function addAuction(address _owner, uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration) internal {

        // daha once uretilmemis ve 0 ile uretilemesin.
        require (auctions[_cardId].cardId == 0 && _cardId != 0);
        
        auctions[_cardId].owner = _owner;
        auctions[_cardId].cardId =_cardId;
        auctions[_cardId].createdTime = now;
        auctions[_cardId].startPrice =_startPrice;
        auctions[_cardId].endPrice =_endPrice;
        auctions[_cardId].duration =_duration;        
        auctionCardIds.push(_cardId);

        uint256 ownerIndex = ownerOfAuctionCardIds[_owner].length;
        ownerOfAuctionCardIds[_owner].push(_cardId);
        ownerOfAuctionCardIdsIndex[_cardId] = ownerIndex;
    }
    
    function removeAuction(address _owner, uint256 _cardId) internal {
        //silinecek kardin sahibi kendisi olmali.
        require( auctions[_cardId].owner == _owner);
        delete auctions[_cardId];
        //genel listeden cikar
        uint256 index = auctionCardIdsIndex[_cardId];
        uint256 lastIndex = auctionCardIds.length -1; //  auctions[_cardId].owner == _owner saglaniyor ise auctionCardIds.length > 0
        uint256 lastCardId = auctionCardIds[lastIndex];
        auctionCardIds[index] = lastCardId;
        auctionCardIds[lastIndex] = 0;
        auctionCardIds.length--;
        auctionCardIdsIndex[_cardId] = 0;
        auctionCardIdsIndex[lastCardId] = index;
        
        //kisinin listesinden cikar.
        index = ownerOfAuctionCardIdsIndex[_cardId];
        lastIndex = ownerOfAuctionCardIds[_owner].length -1; //  auctions[_cardId].owner == _owner saglaniyor ise ownerOfAuctionCardIdsIndex.length > 0
        lastCardId = ownerOfAuctionCardIds[_owner][lastIndex];
        ownerOfAuctionCardIds[_owner][index] = lastCardId;
        ownerOfAuctionCardIds[_owner][lastIndex] = 0;
        ownerOfAuctionCardIds[_owner].length--;
        ownerOfAuctionCardIdsIndex[_cardId] = 0;
        ownerOfAuctionCardIdsIndex[lastCardId] = index;
    }

    function createAuction(address _owner, uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration) public {
        addAuction(_owner, _cardId, _startPrice, _endPrice, _duration);
        //TODO: tranfer yapilacak. 
        // bu metodu cagiranda yapilacak(yeri burasi degil.). markete approve yapacak.
    }

    function cancelAuction(address _owner, uint256 _cardId) public {
        removeAuction(_owner, _cardId);
        //TODO: tranfer yapilacak. 
        // bu metodu cagiranda yapilacak(yeri burasi degil.). approve iptal edecek.
    }

    function bid(address _bidder, uint256 _cardId, uint256 _amount) public {
        //TODO: diger kontroller.
        // 
        address owner = auctions[_cardId].owner;
        removeAuction(owner, _cardId); 

        //TODO: tranfer yapilacak. 
        // 1. asama: ilk once contract kendine transfer yapacak.
        safeTransferFrom( owner, getAddress(), _cardId);
        // 2. asama: contract bidder'a approve verecek.
        approve(_bidder, _cardId);
        // 3. asama: bu metodu cagiranda yapilacak(yeri burasi degil.). kendine transfer yapacak.

    }

    function computeCurrentPrice(uint256 _cardId) public view returns(uint256) {
        //TODO: control auction is exists + method.

        int256 secondsPassed = int256(now) - int256(auctions[_cardId].createdTime);
        int256 startPrice = int256(auctions[_cardId].startPrice);
        int256 endPrice = int256(auctions[_cardId].endPrice);
        int256 duration = int256(auctions[_cardId].duration);
        if (secondsPassed >= duration) {
            return uint(endPrice);
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 totalPriceChange = endPrice - startPrice;

            // This multiplication can't overflow, _secondsPassed will easily fit within
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 currentPriceChange = totalPriceChange * secondsPassed / duration;

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 currentPrice = startPrice + currentPriceChange;

            return uint256(currentPrice);
        }

    }


    //TODO: this code from crypto kitties with a small change.
    // recheck.
    function computeCut(uint256 _price) public view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * market.getOwnerCut() / 10000;
        
    }
    

    //TODO: function: calculate bid amount
    //TODO: function: compute cutof.

}


//#########################################
//###            PLAYERS                ###
//#########################################
library Player {

    struct Data {
        uint256 id; // adress olabilir, yada id kalsın. bakarız.
        address owner; // address olarak degistirildi.
        string name;
        uint256 numberOfStars;
        //baseId -> cardIndex-tokenId
        mapping(uint256 => uint256[]) animalCards;
        //cardId -> index of animalCards[baseId]
        mapping(uint256 => uint256) animalCardsIndex;    
    }
    

    // require carId != 0;
    // oyuncu card'a sahip mi.
    function hasCard(Data storage self, uint256 _baseId, uint256 _cardId ) public view returns(bool _hasCard) {
        require (_cardId != 0 ); // !hasCard(...) _cardId = 0 ile cagrilirsa true dondurmesin. Bunun yerine islemi gerceklestirmesin.        
        if(self.animalCards[_baseId].length != 0) {
            uint256 cardIndex = self.animalCardsIndex[_cardId];
            //bu kartin sahibi mi;                
            if(self.animalCards[_baseId][cardIndex] == _cardId) {
                _hasCard = true;
            }
        }
    }
    

    function addCard(Data storage self, uint256 _baseId, uint256 _cardId) internal returns(bool success){
        //bu card var ekli degilse ve cardId 0 degil ise.
        if(!hasCard(self, _baseId, _cardId)) {
            self.animalCardsIndex[_cardId] = self.animalCards[_baseId].length;
            self.animalCards[_baseId].push(_cardId); 
            success = true;
        } 
    }

    function removeCard(Data storage self, uint256 _baseId, uint256 _cardId) internal returns(bool success) {
        //listesinde bu tip bir kart var mi.
        if(hasCard(self, _baseId, _cardId)) { 

            //TODO CONTROL lValue is not (0 -1)
            uint256 cardIndex = self.animalCardsIndex[_cardId];
            uint256 lastCardIndex = self.animalCards[_baseId].length - 1;
            uint256 lastCard = self.animalCards[_baseId][lastCardIndex];

            self.animalCards[_baseId][cardIndex] = lastCard;
            self.animalCards[_baseId][lastCardIndex] = 0;

            self.animalCards[_baseId].length--;
            self.animalCardsIndex[_cardId] = 0;
            self.animalCardsIndex[lastCard] = cardIndex;
            success = true;

        }
    }
    
}

//TODO: approve'du vs bunun gibi metodlara bir el atilacak.
// sebep: mesela bir kart'i auction'a koydu. contract'i approve edilmektedir.
//   daha sonra disaridan bu approve'yi kaldirirsa, kendi listesinde kart gozukmeyecek.
//  Ve ne bid islemi ne de cancel islemi gerceklestirilemeyecektir.
contract UsingPlayer is UsingPaniniMarket{
    using Player for Player.Data;
    mapping (address => Player.Data) players;
    
    uint256 numberOfPlayer;
    
    function UsingPlayer() public {
        numberOfPlayer = 0;
    }
    
    modifier __isPlayer() {
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
        players[msg.sender].owner = msg.sender;
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

    //checks-1: is card exists.
    //checks-2: is address is player
    function addCardToPlayer(address _address, uint256 _cardId) internal returns(bool success){
        isPlayer(_address);
        if(exists(_cardId)) {
            uint256 baseId = animalCards[_cardId].baseId;
            success = addCardToPlayer(_address, _cardId, baseId);
        }        
    }
    
    function addCardToPlayer(address _address, uint256 _cardId, uint256 _baseId) internal returns(bool success) {
        if (players[_address].addCard(_baseId, _cardId)) {
            animalCards[_cardId].owner = players[_address].owner;        
            players[_address].numberOfStars = players[_address].numberOfStars + 1; // simdilik kart sayisi olsun.             
            success = true;       
        }
    }


    //checks-1: is card exists.
    //checks-2: is address is player
    function removeCardFromPlayer(address _address, uint256 _cardId) internal returns(bool success) {
        isPlayer(_address);
        if(exists(_cardId)) {
            uint256 baseId = animalCards[_cardId].baseId;
            success = removeCardFromPlayer(_address, _cardId, baseId);
        }        
    }
    
    function removeCardFromPlayer(address _address, uint256 _cardId, uint256 _baseId) internal returns(bool success) {
        if(players[_address].removeCard(_baseId, _cardId)) {
            animalCards[_cardId].owner = players[_address].owner;        
            players[_address].numberOfStars = players[_address].numberOfStars - 1; // simdilik kart sayisi olsun.      
            success = true;       
        }
    }


    function addRandomCardToPlayer(address _address) internal {
        isPlayer(_address);
        uint256 baseId = generateRandomCardId();
        //kart'in uretilmesi.
        uint256 cardId = mintCardWithBaseId(_address, baseId);
        addCardToPlayer(_address, cardId, baseId);
    }

    //bu method value degeri girilerek web3 tarafinda cagrilacak.
    function buyPackage(uint256 _numberOfPackage) __isPlayer public payable {
        mutex.enter();

        uint256 price = computePriceOfPackage(_numberOfPackage);
        require (price == msg.value);
        distributeBalance(msg.value);        

        createPackage(msg.sender);

        mutex.left();
    }

    function openPackage(uint256 _packageId) __isPlayer __whenNotPresaled public {
        //paket'i var ise 
        if(isOwnerOfPackage(_packageId) /*TODO: && zamani gelmis mi? */) {
            CardPackage.Data storage package = createdPackages[_packageId];
            //remove first
            removePackage(_packageId);

            addCardToPlayer(msg.sender, package.card1);
            addCardToPlayer(msg.sender, package.card2);
            addCardToPlayer(msg.sender, package.card3);
            addCardToPlayer(msg.sender, package.card4);
            addCardToPlayer(msg.sender, package.card5);
        }       
    }

    //###################
    //     market
    //###################

    //TODO: player'in datasindan silme + guvenlik.
    function createAuction(uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration) __isPlayer public {

        uint256 baseId = animalCards[_cardId].baseId;        
        players[msg.sender].removeCard(baseId, _cardId);        

        //TODO: numberOfStars icin metod yazilacak.
        players[msg.sender].numberOfStars = players[msg.sender].numberOfStars - 1;

        //TODO: sorun olur mu bu sekilde? guvenlik acigi var mi kontrol etmek lazim.       
        //yetkiyi contract'a verdi. 
        //bid isleminde contract once kendine transfer edecek. (nft ile)
        //daha sonra yetkiyi bid islemini yapana verecek.
        //bid islemini yapan da en son tranferi kendine yaparak tamamlayacak.
        //TODO: getAddress -> returns panini address
        approve(address(this), _cardId);
        //card sahibi contract olmali.
        animalCards[_cardId].owner = address(this);

        super.createAuction(msg.sender, _cardId, _startPrice, _endPrice, _duration);
        emit CreateAuction(msg.sender, _cardId, _startPrice, _endPrice, _duration );

    }

    //TODO: player'in datasindan ekleme + guvenlik.
    function cancelAuction(uint256 _cardId) __isPlayer public {

        uint256 baseId = animalCards[_cardId].baseId;
        players[msg.sender].addCard(baseId, _cardId);        
        animalCards[_cardId].owner = msg.sender;          

        //TODO: numberOfStars icin metod yazilacak.
        players[msg.sender].numberOfStars = players[msg.sender].numberOfStars + 1;

        super.cancelAuction(msg.sender, _cardId);

        clearApproval(msg.sender, _cardId);
        emit CancelAuction(msg.sender, _cardId);
    }

    //TODO: player'in datasina ekleme + guvenlik.
    function bid(uint256 _cardId, uint256 _amount) __isPlayer public payable{
        mutex.enter();

        uint256 currentPrice = computeCurrentPrice(_cardId);
        require (currentPrice == msg.value);

        uint256 baseId = animalCards[_cardId].baseId;
        players[msg.sender].addCard(baseId, _cardId);        
        animalCards[_cardId].owner = msg.sender;          
        
        //TODO: numberOfStars icin metod yazilacak.
        players[msg.sender].numberOfStars = players[msg.sender].numberOfStars + 1;
       
        super.bid(msg.sender, _cardId, _amount);

        safeTransferFrom( address(this), msg.sender, _cardId);

        //TODO: tranfer yapilacak. 
        //compute current price
        //compute cut of 
        uint256 cutOf = computeCut(currentPrice);
        // transfer cut of to contract
        distributeBalance(cutOf);        

        currentPrice -= cutOf;
        //transfer owner to currentPrice
        address owner = getOwnerOfAuctionFromCardId(_cardId);
        if(!owner.call.value(currentPrice)()) { throw;}
        emit Bid(owner, msg.sender, _cardId, currentPrice, cutOf);
        mutex.left();
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        return super.balanceOf(_owner);
    }

    function approve(address _to, uint256 _cardId) public {
        // eger auction'da ise token approve yapamamali.
        // card sahibini kontrol etmek yeterli.
        uint256 baseId = animalCards[_cardId].baseId;
        players[msg.sender].hasCard(baseId, _cardId);        
        super.approve(_to, _cardId);
    }

    function clearApproval(address _owner, uint256 _cardId) internal {
        // eger auction'da ise token clear approve yapamamali.
        // card sahibini kontrol etmek yeterli.
        uint256 baseId = animalCards[_cardId].baseId;
        players[msg.sender].hasCard(baseId, _cardId);        
        super.clearApproval(_owner, _cardId);
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
        animalCards[_cardId].owner = players[_to].owner;
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
            if( msg.sender == animalCards[_cardId].owner) {
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

    //TODO: numberOfStars calculation function.


    //fallback
    function () public payable {}
    
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

