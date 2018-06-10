pragma solidity ^0.4.21;

//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
//not: yukaridaki token ozelliklerini kod icerisinde sagliyoruz. Bu yuzden basic gas verimi icin tercih edildi.
//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol";
//importing zaman aliyor. codu iceri tasidim.

library AddressUtils {
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
    return size > 0;
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

//contract -> library
//sebebi: bir bug var. payable bir contract'in metodunda bu contract'in metodlari payeble bile olsa kullaninca 
//"The constructor should be payable if you send value." hatasini firlatiyor.
library Mutex {
  struct Data {
    bool isEntered;
  }

  function enter(Mutex.Data self) pure internal {
    require(!self.isEntered);
    self.isEntered = true;    
  }

  function left(Mutex.Data self) pure internal {
    self.isEntered = false;    
  }
}

contract ERC721Receiver {
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

contract ERC721Basic {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId) public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
    )
  public;
}

contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;
  
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba; 

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      emit Approval(owner, _to, _tokenId);
    }
  }

  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);
    
    emit Transfer(_from, _to, _tokenId);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    safeTransferFrom(_from, _to, _tokenId, "");
  }
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) {
    transferFrom(_from, _to, _tokenId);
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      emit Approval(_owner, address(0), _tokenId);
    }
  }

  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

//randomize icin gerekli olacak.
//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

//Panini ERC721Token
contract PaniniERC721Token is ERC721BasicToken {

  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping (address => uint256[]) internal ownedTokens;
  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] internal allTokens;
  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

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

  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);
    
    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

}


contract AttachingA_PaniniController {
  using AddressUtils for address;
  
  A_PaniniController paniniController;

  modifier __onlyIfA_PaniniController {
    require (msg.sender == address(paniniController));
    _;
  }

  //1 kere set edilebilsin
  //msg.sender bir contract olmali.
  //msg.sender paniniController olmali.
  function attachA_PaniniController() public {    
    require(address(paniniController) == address(0));
    require (msg.sender.isContract() );    
    A_PaniniController candidatePaniniController = A_PaniniController(msg.sender);
    //require (paniniController.isPaniniController());   
    paniniController = candidatePaniniController;      
  }

}

contract A_PaniniState is AttachingA_PaniniController {

  bool public isPaniniState = true;

  bool paused;
  uint256 presaledEndDate;

  event Pause();
  event UnPause();

  function A_PaniniState() public {
  }

  function getPaused() public view returns(bool) {
    return paused;
  }

  function pause() __onlyIfA_PaniniController public {
    paused = true;
  }

  function unPause() __onlyIfA_PaniniController public {
    paused = false;
  }

}



contract HasA_PaniniState {

  A_PaniniState paniniState;
  
  modifier __whenNotPaused() {
    require(!paniniState.getPaused());
    _;
  }

  modifier __whenPaused() {
    require(paniniState.getPaused());
    _;
  }

  //1 kere set edilebilsin
  //is paninistate kontrolu paninicontroller'da yapilmakta.
  function setA_PaniniState(address _address) public {
    require(address(paniniState) == address(0) && _address != address(0) );
    paniniState = A_PaniniState(_address);
  }

  function testA_PaniniState() public view returns(bool) {
    return paniniState.getPaused();
  }
  
}



library CardBase {

  //kullanimi daha kolay.(enum'da disari acmak icin convert gerekiyor..)
  struct Region {
    uint256 ASIA;
    uint256 AFRICA;
    uint256 NOURTH_AMERICA;
    uint256 SOUTH_AMERICA;
    uint256 ANTARCTICA;
    uint256 EUROPE;
    uint256 AUSTRALIA;
    uint256 OCEAN;
  }

  //10 = %10
  struct Rarity {
    uint256 COMMON;
    uint256 RARE;
    uint256 EXOTIC;
  }

  //10 = %10
  //0'dan baslayacak. bu sayede index olarak arr ile kullanilabilecek.
  struct Passive {
    uint256 HEAL_BUFF;
    uint256 POISON;
    uint256 ATTACK_BUFF;
    uint256 ATTACK_DEBUFF;
    uint256 DEFENSE_BUFF;
    uint256 DEFENSE_DEBUFF;
    uint256 SPEED_BUFF;
    uint256 SPEED_DEBUFF;
    uint256 LIFESPAN_BUFF;
    uint256 LIFESPAN_DEBUFF;
  }

  //data
  struct Data {

    //kullanilmayacak, bunun yerine indexler id olacak.
    uint256 id; // arr index: 0: empty initialized and never used.
    string name;
    
    uint256 hp; //health power
    uint256 ap; //attack power
    uint256 deff; //defence
    uint256 speed; //speed
    uint256 weigth; //weight
    
    uint256 lifespan; //life span    
    uint256 region;
    uint256 rarity; // 0-100 arasinda bir sayi. 

    //pasif ozellikler
    uint256 passive;
    uint256 passivePercent; // 10 = %10
  }

  //returns clone of base card.
  function clone(CardBase.Data self) internal pure returns(CardBase.Data) {
    return CardBase.Data(self.id, self.name,
      self.hp, self.ap, self.deff, self.speed, self.weigth,
      self.lifespan, self.region, self.rarity, self.passive, self.passivePercent);
  }

  //returns clone of base card.
  function toTuple(CardBase.Data self) internal pure returns(uint256, string, 
    uint256, uint256, uint256, uint256, uint256,
    uint256, uint256, uint256, uint256, uint256) {

    return (self.id, self.name,
      self.hp, self.ap, self.deff, self.speed, self.weigth,
      self.lifespan, self.region, self.rarity, self.passive, self.passivePercent);
  }

  function fromTuple(CardBase.Data self, uint256 _id, string _name, 
    uint256 _hp, uint256 _ap, uint256 _deff, uint256 _speed, uint256 _weigth, 
    uint256 _lifespan, uint256 _region, uint256 _rarity, uint256 _passive, uint256 _pasivePercent ) internal pure {

      self.id = _id;
      self.name = _name;

      self.hp = _hp;
      self.ap = _ap;
      self.deff = _deff;
      self.speed = _speed;
      self.weigth = _weigth;

      self.lifespan = _lifespan;
      self.region = _region;
      self.rarity = _rarity;

      self.passive = _passive;
      self.passivePercent = _pasivePercent;
  }

}

/**
 * The A_PaniniCard contract does this and that...
 */
 contract A_PaniniCard is AttachingA_PaniniController, HasA_PaniniState {
  using CardBase for CardBase.Data;

  bool public isPaniniCard = true;
  CardBase.Region Region = CardBase.Region(0,1,2,3,4,5,6,7);
  CardBase.Rarity Rarity = CardBase.Rarity(70,25,5);
  CardBase.Passive Passive = CardBase.Passive(0,1,2,3,4,5,6,7,8,9);

  //server tarafinda her create'te db guncellenecek. Bu sayede base card'larin listesi goruntulenebilecek.
  event CreatedAnimalCard(uint256 _id, string _name, 
    uint256 _hp, uint256 _ap, uint256 _deff, uint256 _speed, uint256 _weigth, 
    uint256 _lifespan, uint256 _region, uint256 _rarity, uint256 _pasive, uint256 _pasivePercent );

  // metedata
  CardBase.Data[] cardBaseList; 
  
  function A_PaniniCard () public {
    initCardBase();
  }  

  function initCardBase() internal {
    //id'lerin indexler ile ayni olmasi icin eklendi. Kullanilmayacak. bunun id'si 0.
    _createCardBase('empty', 0, 0, 0, 0, 0, 
      0, Region.AFRICA, Rarity.COMMON, Passive.HEAL_BUFF, 0 );        

    //name, hp, ap, deff, speed, weight, 
    //lifespan, region, rarity, passive, passivePercent
    /*
    _createCardBase('name', hp, ap, def, sp, wg,
      lp, CardBase.Region.AFRICA, CardBase.Rarity.RARE, CardBase.Passive.ATTACK_BUFF, 10 );        
    */
    _createCardBase('fil', 10000, 1000, 300, 80, 6000,
      60, Region.AFRICA, Rarity.RARE, Passive.DEFENSE_BUFF, 10 );        
    _createCardBase('at', 700, 30, 120, 120, 500,
      30, Region.ASIA, Rarity.COMMON, Passive.SPEED_BUFF, 5 );        
    _createCardBase('tavsan', 20, 30, 20, 50, 2,
      6, Region.EUROPE, Rarity.COMMON, Passive.LIFESPAN_BUFF, 10 );        
    _createCardBase('aslan', 1000, 500, 300, 70, 250,
      20, Region.AFRICA, Rarity.RARE, Passive.ATTACK_BUFF, 10 );        
    _createCardBase('balina', 5000, 10, 100, 60, 30000,
      120, Region.OCEAN, Rarity.EXOTIC, Passive.HEAL_BUFF, 3 );        
    _createCardBase('yunus', 100, 30, 100, 100, 200,
      40, Region.OCEAN, Rarity.RARE, Passive.HEAL_BUFF, 2 );        
    _createCardBase('kilic baligi', 60, 120, 200, 120, 50,
      30, Region.OCEAN, Rarity.EXOTIC, Passive.DEFENSE_DEBUFF, 10 );        
    _createCardBase('kartal', 20, 100, 80, 120, 20,
      20, Region.ASIA, Rarity.RARE, Passive.SPEED_BUFF, 10 );        
    //mesela guvercin gucsuz bir hayvan. Bunu 5 yil boyunca sagladigi %20 heal buff ile fazlasi ile telafi etmekte.
    // %20 buff cok ama cok iyi bir rakam. Bu rakam 5 yil boyunca partisi cok iyi korur.
    //degisik kombinasyonlar olabilir, oyunculara kaldi artik, ama bu kadar farkli secenekler sanirim oldukca buyuk uzay saglamakta.
    _createCardBase('guvercin', 5, 1, 1, 20, 1,
      5, Region.SOUTH_AMERICA, Rarity.COMMON, Passive.HEAL_BUFF, 20 );        
    //mesela karinca, gucercin gibi ayni sekilde, ilk 3 yil rakibin defansini oyle bir dusurur ki, oyuna hizli baslayip bitirmek isteyen oyuncular icin bire-bir.
    _createCardBase('karinca', 1, 1, 1, 1, 0,
      3, Region.ASIA, Rarity.COMMON, Passive.DEFENSE_DEBUFF, 30 );        

  }

  // usuable id between 1 to (n-1)
  function existCardBase(uint256 _baseId) public view returns(bool) {
    if( _baseId > 0 && _baseId <= cardBaseList.length) {
      return true;
    }
    return false;                
  }

  //usuable card id starts with 1.
  function _createCardBase(string _name, 
    uint256 _hp, uint256 _ap, uint256 _deff, uint256 _speed, uint256 _weigth, 
    uint256 _lifespan, uint256 _region, uint256 _rarity, uint256 _pasive, uint256 _pasivePercent ) internal{

    uint256 id = cardBaseList.length;
    cardBaseList.push(CardBase.Data(id, _name,
      _hp, _ap, _deff, _speed, _weigth,
      _lifespan, _region, _rarity, _pasive, _pasivePercent));
  }

  // usuable card id starts with 1.
  // __onlyIfA_PaniniController
  function createCardBase(string _name, 
    uint256 _hp, uint256 _ap, uint256 _deff, uint256 _speed, uint256 _weigth, 
    uint256 _lifespan, uint256 _region, uint256 _rarity, uint256 _pasive, uint256 _pasivePercent ) __onlyIfA_PaniniController public {
    _createCardBase(_name,
      _hp, _ap, _deff, _speed, _weigth,
      _lifespan, _region, _rarity, _pasive, _pasivePercent );
  }

  //returns index of animalCardBase
  function generateRandomBaseId(uint256 random) public view returns (uint256) {
    //private test for random
    uint256 id = cardBaseList.length;
    uint256 delta = cardBaseList.length;
    require(delta > 0);

    id = (  random  * ( id + 2 ) * ( 3 * id + 2 ) ) % delta;
    return id;

    // random'u nasil yapacagiz buna karar verilecek.
    //kartlar eklenirken bir islem yapilacak. random card genereate ederken secim buna gore. bir array'den index cikartilacak.
  }
    //err: solidity stack too deep
/*  function getCardBaseTupple(uint256 _baseId) public view returns(uint256, string, 
    uint256, uint256, uint256, uint256, uint256,
    uint256, uint256, uint256, uint256, uint256) {
    require( _baseId > 0 && _baseId <= cardBaseList.length);
    return cardBaseList[_baseId].toTuple();
  }
 */
  function getCardBaseActiveTuple(uint256 _baseId) public view returns(uint256, string, 
    uint256, uint256, uint256, uint256, uint256,
    uint256, uint256, uint256, uint256, uint256) {
    require( _baseId > 0 && _baseId <= cardBaseList.length);
    return cardBaseList[_baseId].toTuple();
  }
  function getCardBasePassiveTuple(uint256 _baseId) public view returns(uint256, string, 
    uint256, uint256, uint256, uint256, uint256,
    uint256, uint256, uint256, uint256, uint256) {
    require( _baseId > 0 && _baseId <= cardBaseList.length);
    return cardBaseList[_baseId].toTuple();
  }
}



contract A_PaniniCardPackage is AttachingA_PaniniController, HasA_PaniniState {
 
  event PackageCreated(uint256 id, address receiver, uint256 baseId1, uint256 baseId2, uint256 baseId3, uint256 baseId4, uint256 baseId5 );

  struct PackagePrice{
    uint256 normal;
    uint256 initial;
    uint256 special;
  }

  bool public isPaniniCardPackage = true;

  A_PaniniCard paniniCard;

  uint256 numberOfPackageCreated;

  //package gecmisi tutulacak mi?    
  PackagePrice packagePrice;

  function A_PaniniCardPackage() public{
    packagePrice.normal = 5000000000000000000; //0.05 ether
    packagePrice.initial = 1000000000000000000; //0.01 ether
    packagePrice.special = 3000000000000000000; //0.03 ether
  }  

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniCard(address _address) __onlyIfA_PaniniController public {    
    require(address(paniniCard) == address(0) && _address != address(0) );
    paniniCard = A_PaniniCard(_address);         
  }

  function createPackage(address _address) public view returns(uint256, uint256, uint256, uint256, uint256){
    numberOfPackageCreated += 1; //ayni zamanda package id.
    uint256 packageId = numberOfPackageCreated;

    //generating cards bases
    uint256 baseId1 = paniniCard.generateRandomBaseId(numberOfPackageCreated);
    uint256 baseId2 = paniniCard.generateRandomBaseId(numberOfPackageCreated * baseId1);
    uint256 baseId3 = paniniCard.generateRandomBaseId(numberOfPackageCreated * baseId2);
    uint256 baseId4 = paniniCard.generateRandomBaseId(numberOfPackageCreated * baseId3);
    uint256 baseId5 = paniniCard.generateRandomBaseId(numberOfPackageCreated * baseId4);
    emit PackageCreated(packageId, _address, baseId1, baseId2, baseId3, baseId4, baseId5);
    return (baseId1, baseId2, baseId3, baseId4, baseId5);
  }

  //fiyatlar sonradan degistirilemesin?
  function computePriceOfPackage(uint _numberOfPackage) public view returns(uint256 price) {
   //initial price
   if(numberOfPackageCreated <= 100/*TODO: && now < paniniState.presaledEndDate*/) {
    uint remaining = 100 - numberOfPackageCreated;
    //to do: sadece presale icin olacak.
    if(_numberOfPackage < remaining ) {
      //TO DO: check owerflow?
      price = _numberOfPackage * packagePrice.initial;
    } else {
      price = (remaining * packagePrice.initial) + ((_numberOfPackage - remaining) * packagePrice.normal);
    } 

    //normal price
    } else {
      price = _numberOfPackage * packagePrice.normal;
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

contract A_PaniniMarket is AttachingA_PaniniController, HasA_PaniniState, ERC721Receiver {
  using Auction for Auction.Data;

  event CreateAuction(address owner, uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration);
  event CancelAuction(address owner, uint256 _cardId);
  event Bid(address owner, address sender, uint256 _cardId, uint256 amount);

  bool public isPaniniMarket = true;


  // Values 0-10,000 map to 0%-100%
  uint256 ownerCut;

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
  
  // Reference to contract tracking NFT ownership
  PaniniERC721Token nft; // panini

  function A_PaniniMarket() public {
    ownerCut = 1200; //12% cutof. 
  }

  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4) {
    return ERC721_RECEIVED;
  }

  //TODO: 1 kez set edilecek sekilde degistirilecek.
  //sadece paniniController set edebilsin.
  function setNFT(address _address) __onlyIfA_PaniniController public {  
    require(address(nft) == address(0) && _address != address(0) );        
    nft = PaniniERC721Token(_address);
    //nft erc721 mi?
    //TODO: check if nft is erc721
  }

  function getOwnerCut() public view returns(uint256) {
    return ownerCut;
  }

  function getCardsInAuctions( ) public view returns(uint256[]) {
    return auctionCardIds;
  }
  
  function getCardsInAuctionsOfOwner( address _owner) public view returns(uint256[]) {
    return ownerOfAuctionCardIds[_owner];
  }

  function getAuctionInfo( uint256 _cardId ) public view returns(
    address,
    uint256,
    uint256,
    uint256,
    uint256,
    uint256) {

    require (auctions[_cardId].cardId == _cardId && _cardId != 0);
    address owner = auctions[_cardId].owner;
    uint256 cardId = auctions[_cardId].cardId;
    uint256 createdTime = auctions[_cardId].createdTime;
    uint256 startPrice = auctions[_cardId].startPrice;
    uint256 endPrice = auctions[_cardId].endPrice;
    uint256 duration = auctions[_cardId].duration;    
    return (owner, cardId, createdTime, startPrice, endPrice, duration);
  }



  function getOwnerOfAuctionFromCardId(uint256 _cardId) public view returns(address) {
    require (auctions[_cardId].cardId == 0 && _cardId != 0);
    return auctions[_cardId].owner;
  }


  function _addAuction(address _owner, uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration) internal {

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
  
  function _removeAuction(address _owner, uint256 _cardId) internal {
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

  //note: bu metodun cagrildigi yerde cagiran approve yapmali
  function createAuction(address _owner, uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration) public {
    //is owner of card 
    require ( nft.ownerOf(_cardId) == _owner );
    
    _addAuction(_owner, _cardId, _startPrice, _endPrice, _duration);
    nft.safeTransferFrom(_owner, address(this), _cardId);
    emit CreateAuction(_owner, _cardId, _startPrice, _endPrice, _duration );
  }

  function cancelAuction(address _owner, uint256 _cardId) public {
    _removeAuction(_owner, _cardId);
    nft.approve(_owner, _cardId);
    emit CancelAuction(_owner, _cardId);
  }

  function bid(address _bidder, uint256 _cardId, uint256 _amount) public {
    address owner = auctions[_cardId].owner;
    _removeAuction(owner, _cardId); 
    nft.approve(_bidder, _cardId);
    emit Bid(owner, _bidder, _cardId, _amount);

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
  return _price * getOwnerCut() / 10000;

  }

}


/**
 * The PaniniBase 
 */
 contract PaniniBase is AttachingA_PaniniController, HasA_PaniniState {
  using Mutex for Mutex.Data;

  bool public isPaniniBase = true;

  A_PaniniCard paniniCard;
  A_PaniniCardPackage paniniCardPackage;
  A_PaniniMarket paniniMarket;

  //for security
  Mutex.Data mutex;

  function PaniniBase() public{
    mutex = Mutex.Data(false);

  }  

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniCard(address _address) __onlyIfA_PaniniController public {    
    require(address(paniniCard) == address(0) && _address != address(0) );
    paniniCard = A_PaniniCard(_address);         
  }

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniCardPackage(address _address) __onlyIfA_PaniniController public {
    require(address(paniniCardPackage) == address(0) && _address != address(0) );
    paniniCardPackage = A_PaniniCardPackage(_address);
  }

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniMarket(address _address) __onlyIfA_PaniniController public {
    require(address(paniniMarket) == address(0) && _address != address(0) );
    paniniMarket = A_PaniniMarket(_address);
  }
  
}



contract UsingCard is PaniniBase, PaniniERC721Token {
  //ANIMAL CARDS
  // Bu deger her card uretildiginde emit ile server tarafinda tutulacak. Ve arayuzde oradan gosterilecek.
  //mapping (uint256 => uint256[]) baseIdToCardIdList;

  uint256 lastMintedCardId; // listeye gerek yok. eger liste olsaydı su sekilde olacaktı [0,1,2,3,4,5,6..n]  
  mapping (uint256 => uint256) cardIdToBaseId;
  //token generate etmek icin;
  

  function UsingCard() public {

  }
  

  //cart üretilmesi için.
  //token kullanacak.
  //to: token icin. 
  //baseId: random generated value of basecard index. 
  function _mintCardWithBaseId(address _to, uint256 _baseId) internal returns(uint256){
    
    lastMintedCardId++;
    uint256 cardId = lastMintedCardId;
    super._mint(_to, cardId);
    // set baseId of metedata
    cardIdToBaseId[cardId] = _baseId;
    return cardId;
  }

  function _mintRandomCard(address _to) internal returns(uint256) {
    uint256 baseId = paniniCard.generateRandomBaseId(lastMintedCardId);
    //kart'in uretilmesi.
    return _mintCardWithBaseId(_to, baseId);
  }
/*
  function getAnimalCardInfo(uint256 _cardId) public view returns(uint256, string, uint256, uint256, uint256, uint256, uint256) {
    uint256 baseId = cardIdToBaseId[_cardId];
    if(baseId != 0) {
      return paniniCard.getCardBaseTupple(baseId);
    }    
    return (0,'0',0,0,0,0,0);
  }
*/
}


//#########################################
//###            PLAYERS                ###
//#########################################
//server'da register.
//bir liste tut serverda

//TODO: approve'du vs bunun gibi metodlara bir el atilacak.
// sebep: mesela bir kart'i auction'a koydu. contract'i approve edilmektedir.
//   daha sonra disaridan bu approve'yi kaldirirsa, kendi listesinde kart gozukmeyecek.
//  Ve ne bid islemi ne de cancel islemi gerceklestirilemeyecektir.
contract Player is UsingCard{

 struct Data {
    uint256 id; 
    string name;
    //server'da tutulacak. 
    //TODO: nasil goruntuleyecek? nasil serverda tutulacak?
    // emit (address, cardId, baseId)?
    //baseId -> cardIndex-tokenId
//    mapping(uint256 => uint256[]) animalCards;
    //cardId -> index of animalCards[baseId]
//    mapping(uint256 => uint256) animalCardsIndex;    
  }
  
  mapping (address => Data) players;
  uint256 numberOfPlayer;

  function Player() public {

  }

  modifier __isPlayer() {
    require(players[msg.sender].id != 0);
    _;
  }

  function isPlayer(address _address) internal view{
    require(players[_address].id != 0);
  }

  function register(string _name) __whenNotPaused public {
    require(players[msg.sender].id == 0);
    numberOfPlayer = numberOfPlayer + 1;
    players[msg.sender].id = numberOfPlayer;
//    players[msg.sender].owner = msg.sender;
    players[msg.sender].name = _name;
    //5x card 
    _mintRandomCard(msg.sender);
    _mintRandomCard(msg.sender);
    _mintRandomCard(msg.sender);
    _mintRandomCard(msg.sender);
    _mintRandomCard(msg.sender);
  }    

  function getPlayerName() __isPlayer public view returns(string) {
    return players[msg.sender].name;
  }


  //bu method value degeri girilerek web3 tarafinda cagrilacak.
  function buyPackage(uint256 _numberOfPackage) __isPlayer __whenNotPaused public payable {
    mutex.enter();

    uint256 price = paniniCardPackage.computePriceOfPackage(_numberOfPackage);
    require (price == msg.value);
    uint256 baseId1;
    uint256 baseId2;
    uint256 baseId3;
    uint256 baseId4;
    uint256 baseId5;
    
    for(uint256 i = 0; i < _numberOfPackage; i++) {
      (baseId1, baseId2, baseId3, baseId4, baseId5) 
        = paniniCardPackage.createPackage(msg.sender);
      _mintCardWithBaseId(msg.sender, baseId1);
      _mintCardWithBaseId(msg.sender, baseId2);
      _mintCardWithBaseId(msg.sender, baseId3);
      _mintCardWithBaseId(msg.sender, baseId4);
      _mintCardWithBaseId(msg.sender, baseId5);
    }
    //TODO: bu distributeBalance artik paniniState'de. El atilacak.
    require(address(paniniController).call.value(msg.value)());
    paniniController.distributeBalance(msg.value);        
    mutex.left();
  }


//TODO: player'in datasindan silme + guvenlik.
function createAuction(uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration) __isPlayer __whenNotPaused public {

  approve(address(paniniMarket), _cardId);
  paniniMarket.createAuction(msg.sender, _cardId, _startPrice, _endPrice, _duration);

}

//TODO: player'in datasindan ekleme + guvenlik.
function cancelAuction(uint256 _cardId) __isPlayer __whenNotPaused public {

  paniniMarket.cancelAuction(msg.sender, _cardId);
  safeTransferFrom(address(paniniMarket), msg.sender, _cardId);
  clearApproval(msg.sender, _cardId);
}

//TODO: player'in datasina ekleme + guvenlik.
function bid(uint256 _cardId) __isPlayer __whenNotPaused public payable{
  mutex.enter();

  uint256 currentPrice = paniniMarket.computeCurrentPrice(_cardId);
  
  //Fazla girebilsin. sonra fazlasini geri ver oyuncuya.
  require (currentPrice <= msg.value);

  uint256 bidExcess = msg.value - currentPrice;

  paniniMarket.bid(msg.sender, _cardId, msg.value);

  safeTransferFrom( address(paniniMarket), msg.sender, _cardId);

  //TODO: tranfer yapilacak. 
  //compute current price
  //compute cut of 
  uint256 cutOf = paniniMarket.computeCut(currentPrice);
  // transfer cut of to contract
  require(address(paniniController).call.value(cutOf)());
  paniniController.distributeBalance(cutOf);        

  currentPrice -= cutOf;
  //transfer owner to currentPrice
  address owner = paniniMarket.getOwnerOfAuctionFromCardId(_cardId);
  require(owner.call.value(currentPrice)());

  if(bidExcess > 0 ) {
    //fazla girebilecek degieri. Parasi geri verilecek.
    require(msg.sender.call.value(bidExcess)());
  }

  mutex.left();
}

//TODO: controller tarafindan bu addresin eklenip eklenemeyecegi kontrol edilecek.
//Oyun contract'ina butun tokenlerinin alim-satimi icin yetki verir.
function addGameToStore(address gameAddress) __isPlayer{
  //TODO : controlls. 
  //TODO: myGames olmali. Bu oyunlar gameBase'den belli metodlari almali. 
  //   Orn score gosterme gibi. Oyuncunun ana ekraninda oyunlari icin score'lari gosterebilecek.
  //simdilik sadece yetki versin.
  setApprovalForAll(gameAddress, true);  
}

//TODO: controller tarafindan bu addresin eklenip eklenemeyecegi kontrol edilecek.
//Oyun contract'indan butun tokenlerinin alim-satimi icin verdiği yetkiyi kaldirir.
function removeGameToStore(address gameAddress) __isPlayer{
  //TODO : controlls. 
    setApprovalForAll(gameAddress, false); 
}

/*
// TODO: bu method degistirilecek. belkide gerek yok. Token standartinin extend hali sanki address -> token list veriyordu.
// sonrada kontrol edilecek ve eklenecek
    function getMyAllCardIds() __isPlayer public view returns(uint256[]) {

      uint256[] memory cards = new uint256[](animalCardBase.length);
      for(uint256 i = 1; i < animalCardBase.length; i++) {
        cards[i] = players[msg.sender].animalCards[i].length;
      }
      return cards;
    }*/

    //TODO: score calculation function.

  }






//#########################################
//###             PANINI                ###
//#########################################
//player oyunu direk oynayabilecek.
//burada onemli nokta: bu contract'tan escrow yapilabilmeli.
//3. parti bir oyun gibi dusunebiliriz.
// ERC721Receiver olmali.
// PaniniState'i olmali.
// Player'i olmali
// A_PaniniCard olmali.
// Onemli: Token standartinda bulunan setApprovalForAll'in player tarafindan bu contract icin aktif hale getirilmis olmasi gerekmekte..
// Player oyunu Player contract'inda ekleyecek. (Guvenligi bir sekilde saglayacagim. Ayni token standart'i gibi bizim de bir oyun standartimiz olmali.)
// Soru: peki player approval'i kaldirir ise? 
//   1. Mevcut oyun devam edecek. Zaten contract rehin almisti kartlari.
//   2. oyun baslatamayacak. Bu zaten approval vermediyse gerceklesmeyecektir.
//   Aslinda oyunu ekleyip cikarmis oluyor. 
//   3. Approval verdigi oyunun bizim controller tarafindan onaylanmis olmasi gerekiyor. Yanlis address'e setApprovalForAll vermemeli.
//      3.1 Controller'a oyun eklenebilmeli.
//      3.2 cikartilabilmeli mi?
//   4. activate game. deActivate game.
contract A_PaniniGameBase is HasA_PaniniState, ERC721Receiver{
  using CardBase for CardBase.Data;

  // Reference to contract tracking NFT ownership
  // player ve nft ayni address. Player has ERCTokens.
  //kodlama kolayligi olmasi acisindan nft islemleri burada nft degiskeninden yapilacak.
  Player playerContract;
  PaniniERC721Token nft;
  A_PaniniCard paniniCard;

  mapping (uint256 => address) escrowedCardOwners;  

  function A_PaniniGameBase() public {

  }

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniCard(address _address) public {    
    require(address(paniniCard) == address(0) && _address != address(0) );
    paniniCard = A_PaniniCard(_address);         
  }

  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4) {
    return ERC721_RECEIVED;
  }

  //TODO: 1 kez set edilecek sekilde degistirilecek.
  //TODO: sadece paniniController set edebilsin.
  //Bunu bir liste olarak ekleyecegim controller'a.
  function setPlayerContract(address _address) public {  
    require(address(playerContract) == address(0) && _address != address(0) );        
    playerContract = Player(_address);
    nft = PaniniERC721Token(_address);
    //nft erc721 mi?
    //TODO: check if nft is erc721
  }

  //escrow 
  //butun oyunlarda kart'larin rehin alinma ozelligi olsun.
  //bu sayede islemleri yapabilir.
  //ONEMLI: bu method sadece ve sadece player bu contract'a appraveAll yetkisini verdiyse calisacak.
  //Bu metod'un kullanildigi metodlar guvenli. Cunku safetransfer to contract islemi burada gerceklesmekte.
  function _escrow(uint256 _cardId) internal{
    address owner = nft.ownerOf(_cardId);
    nft.safeTransferFrom(address(this), address(msg.sender), _cardId);
    escrowedCardOwners[_cardId] = owner;
    //TODO: emit escrow.
  }

  //escrow alinan kartin transfer edilmesi.
  //sadece kart'in escrow alinip alinmadigini kontrol eder ve transfer eder.  
  function _transfer(address _to, uint256 _cardId) internal{
    require(escrowedCardOwners[_cardId] != address(0));
    nft.approve( _to, _cardId);
    nft.safeTransferFrom(address(msg.sender), _to, _cardId);
    delete escrowedCardOwners[_cardId];
    //TODO: emit escrow.
  }

}

library Game1 {
  struct Herd {
    address owner;
    //active cards
    uint256 card1;
    uint256 card2;
    uint256 card3;
    uint256 card4;
    //passive cards
    uint256 card5;
    uint256 card6;
    uint256 card7;
    uint256 card8;
  }

  struct Data {
    uint256 id;  //0 olabilir.
    address player1;
    address player2;
    uint256 startTime;
    Herd herdOfPlayer1;
    Herd herdOfPlayer2;    
  }
  
  struct ActiveCard {
    uint256 hpMax; // heal/poison icin. +  //buff katilmis hali.
    uint256 hp; // starts with max.
    uint256 ap; //buff katilmis hali.
    uint256 deff; //buff katilmis hali.
    uint256 sp; //buff katilmis hali.
    uint256 weigth; //buff katilmis hali.
    uint256 life; //buff katilmis hali.
    uint256 region;    
  }

  struct PassiveCard {
    uint256 life; //buff katilmis hali.
    uint256 passive;
    uint256 percentage;
  }
  
}

//GAME-1
//oyun'un hazir hale getirilmesi.
//1. controller'a ekle. (Controller tarafinda.)
//2. state'i ekle. (setState metodunu kulanarak.)
contract A_PaniniGame1 is A_PaniniGameBase{
  using Game1 for Game1.Data;
  int256 NEW_PLAYER_SCORE = 1200;
  int256 MIN_SCORE = 800;
  int256 MAX_SCORE = 2800;
  int256 SCORE_GAP = 50;

  address[] players;
  mapping (address => uint256) playersIndex;
  mapping (address => int256) playerScore;
  
  //binary tree balance olmayacagi icin(balance yapmak oyuncuya masraf.), search log(n)'de calisacak sekilde ziplayacak.
  //tree yerine atliyarak gitse? Ortadan baslasa search'e? bole bole gitse?
  //Game1.Data[] pendingGames; 

  //hash map of arrays in score window
  //800-> 800-850 , 850-900, 900-950
  //1123 ->1100
  mapping (int256 => Game1.Data[]) pendingGames;
  
  uint256 numberOfGames;

  mapping (uint256 => Game1.Data) startedGames;
  //mapping (uint256 => Game1.Data) finishedGames;

  //butun oyuncularin oyunlarinin listesi? 
  uint256[] games;
  //Bir oyuncuya ait oynlarin listesi 
  mapping (address => uint256[]) myGames;    

  function A_PaniniGame1() public {
  }

  function getMyGames() public view returns(uint256[]) {
    return myGames[msg.sender];
  }
  

  //returns 800 - 1200  : 1k = 1.
  function _calculateWeightFactor(uint256 _weight1, uint256 _weight2 ) internal returns(uint256) {
    //kusurat icin *1000    
    uint256 w = (_weight1*100) / _weight2; 
    if(w <= 50) {
      return 2*w + 800;
    } else if(w <= 300) {
      return w + 900;
    }
    return 1200; 
  }

  // 0-1000(for %0-100). no limit.
  function _calculateDeffFactor(uint256 _deff ) internal returns(uint256) {
    //kusurat icin *1000    
    if(_deff <= 250) {
      return _deff*10;
    } else if(_deff <= 500) {
      return 8*_deff + 500;
    } else if(_deff <= 1000) {
      return 5*_deff + 2500;
    }
    return 2*_deff + 5000;
  }

  //ap: ~400
  //sp: ~250
  //wf: ~1000
  //(ap*sp*wf) : ~10^8
  //df: ~1000(max) : normalde 500 civaridir.x10
  //(dk*5xAp*5xSp) :(60*5*5 = 1500) : 1.5*10^3
  //(1.5*10^3*df) ~1.5*10^6
  //return: ~ (10^8) / (1.5*10^6) : ~100/1.5 = 66(1k deff icin.), 130(500 deff icin.) 
  //orn: bir fil(TANK)'in cani 1000 ise => ~10 tur'da gidici.  
  function _calculateDamage(uint256 _ap, uint256 _sp, uint256 _wf, uint256 _df ) internal returns(uint256) {
    return (_ap*_sp*_wf) / (15000*_df);//x10 df
  }
  
  // 0 => not end.
  // 1 => player1 winner
  // 2 => player2 winner
  // 3 => draw
  function _calculateGameState(uint256 _gameId, uint256 _time) internal returns(uint256) {
    Game1.Data memory game = startedGames[_gameId];
    
    //player1 data
    Game1.ActiveCard[] memory p1ActiveCards = new Game1.ActiveCard[](4);
    Game1.PassiveCard[] memory p1PassiveCards = new Game1.PassiveCard[](4);
    uint256[] memory p1Buffs = new uint256[](10);
    uint256[] memory p1Regions = new uint256[](8); 
    uint256 p1DeffFactor;
    uint256 p1Damage;
    uint256 p1DefanderCardIndex;
    //yardimci degerler-total.
    uint256 p1Ap;
    uint256 p1Sp;
    uint256 p1Deff;
    uint256 p1Weight;

    //player2 data
    Game1.ActiveCard[] memory p2ActiveCards = new Game1.ActiveCard[](4);
    Game1.PassiveCard[] memory p2PassiveCards = new Game1.PassiveCard[](4);
    uint256[] memory p2Buffs = new uint256[](10);
    uint256[] memory p2Regions = new uint256[](8); 
    uint256 p2DeffFactor;
    uint256 p2Damage;
    uint256 p2DefanderCardIndex;
    //yardimci degerler-total.
    uint256 p2Ap;
    uint256 p2Sp;
    uint256 p2Deff;
    uint256 p2Weight;
    
    uint256 weigthFactor;

    //kartlarin set edilmesi.      
    //player1    
    //aktiveCards.
    uint256 _hp; 
    uint256 _ap;
    uint256 _deff;
    uint256 _sp;
    uint256 _weigth;
    uint256 _life;
    uint256 _region;
    uint256 _lifespan;
    uint256 _pasive;
    uint256 _pasivePercent;
    
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card1);
    p1ActiveCards[0] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card2);
    p1ActiveCards[1] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card3);
    p1ActiveCards[2] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card4);
    p1ActiveCards[3] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    //passiveCards.
    //Bos olabilir. // _getPassiveCardTuple returns (0,0,0);
    if(game.herdOfPlayer1.card5 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent) 
        = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card5);
      p1PassiveCards[0] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }
    if(game.herdOfPlayer1.card6 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent)
       = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card6);
      p1PassiveCards[1] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }
    if(game.herdOfPlayer1.card7 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent)
       = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card7);
      p1PassiveCards[2] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }
    if(game.herdOfPlayer1.card8 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent)
       = paniniCard.getCardBaseTupple(game.herdOfPlayer1.card8);
      p1PassiveCards[3] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }

    //bufflarin hesaplanmasi.
    p2Buffs[p1PassiveCards[0].passive] += p1PassiveCards[0].percentage;
    p2Buffs[p1PassiveCards[1].passive] += p1PassiveCards[1].percentage;
    p2Buffs[p1PassiveCards[2].passive] += p1PassiveCards[2].percentage;
    p2Buffs[p1PassiveCards[3].passive] += p1PassiveCards[3].percentage;
    
    //region bufflarin hesaplanmasi -> sonra.
    p1Regions[p1ActiveCards[0].region] += 1;
    p1Regions[p1ActiveCards[1].region] += 1;
    p1Regions[p1ActiveCards[2].region] += 1;
    p1Regions[p1ActiveCards[3].region] += 1;

    //player2    
    //aktiveCards.
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card1);
    p2ActiveCards[0] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card2);
    p2ActiveCards[1] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card3);
    p2ActiveCards[2] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    (,,_hp, _ap, _deff, _sp, _weigth, _life, _region,,,) 
      = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card4);
    p2ActiveCards[3] = Game1.ActiveCard(_hp, _hp, _ap, _deff, _sp, _weigth, _life, _region);
    //Bos olabilir. // _getPassiveCardTuple returns (0,0,0);
    if(game.herdOfPlayer2.card5 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent) 
        = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card5);
      p2PassiveCards[0] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }
    if(game.herdOfPlayer2.card6 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent)
       = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card6);
      p2PassiveCards[1] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }
    if(game.herdOfPlayer2.card7 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent)
       = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card7);
      p2PassiveCards[2] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }
    if(game.herdOfPlayer2.card8 != 0) {
      (,, 
      ,,,,, 
      _lifespan,,, _pasive, _pasivePercent)
       = paniniCard.getCardBaseTupple(game.herdOfPlayer2.card8);
      p2PassiveCards[3] = Game1.PassiveCard(_lifespan, _pasive, _pasivePercent);
    }

    //bufflarin hesaplanmasi.
    p2Buffs[p2PassiveCards[0].passive] += p2PassiveCards[0].percentage;
    p2Buffs[p2PassiveCards[1].passive] += p2PassiveCards[1].percentage;
    p2Buffs[p2PassiveCards[2].passive] += p2PassiveCards[2].percentage;
    p2Buffs[p2PassiveCards[3].passive] += p2PassiveCards[3].percentage;
    //region bufflarin hesaplanmasi -> sonra.
    p2Regions[p2ActiveCards[0].region] += 1;
    p2Regions[p2ActiveCards[1].region] += 1;
    p2Regions[p2ActiveCards[2].region] += 1;
    p2Regions[p2ActiveCards[3].region] += 1;

    //calculation
    //yardimci degerler
    p1Ap = p1ActiveCards[0].ap +
      p1ActiveCards[1].ap +
      p1ActiveCards[2].ap +
      p1ActiveCards[3].ap;
    p1Sp = p1ActiveCards[0].sp +
      p1ActiveCards[1].sp +
      p1ActiveCards[2].sp +
      p1ActiveCards[3].sp;
    p1Weight = p1ActiveCards[0].weigth +
      p1ActiveCards[1].weigth +
      p1ActiveCards[2].weigth +
      p1ActiveCards[3].weigth;
    p1Deff = p1ActiveCards[0].deff +
      p1ActiveCards[1].deff +
      p1ActiveCards[2].deff +
      p1ActiveCards[3].deff;
    
    p2Ap = p2ActiveCards[0].ap +
      p2ActiveCards[1].ap +
      p2ActiveCards[2].ap +
      p2ActiveCards[3].ap;
    p2Sp = p2ActiveCards[0].sp +
      p2ActiveCards[1].sp +
      p2ActiveCards[2].sp +
      p2ActiveCards[3].sp;
    p2Weight = p2ActiveCards[0].weigth +
      p2ActiveCards[1].weigth +
      p2ActiveCards[2].weigth +
      p2ActiveCards[3].weigth;
    p2Deff = p2ActiveCards[0].deff +
      p2ActiveCards[1].deff +
      p2ActiveCards[2].deff +
      p2ActiveCards[3].deff;

    weigthFactor = _calculateWeightFactor( p1Weight, p2Weight);

    p1DeffFactor = _calculateDeffFactor(p1Deff);
    p2DeffFactor = _calculateDeffFactor(p2Deff);
    p1Damage = _calculateDamage( p1Ap, p1Sp, weigthFactor, p2DeffFactor );
    p2Damage = _calculateDamage( p2Ap, p2Sp, weigthFactor, p1DeffFactor );

    //iki saldiri'da ayni anda yapilacak.
    //60 => 60 sec.(1min) 
    for(uint256 i = game.startTime; i < _time; i = i + 60) {
      //saldiri.
      if(p1ActiveCards[p1DefanderCardIndex].hp <= p2Damage) {
        //died.
        p1ActiveCards[p1DefanderCardIndex].hp = 0;
      } else {
        p1ActiveCards[p1DefanderCardIndex].hp -= p2Damage;
      }

      if(p2ActiveCards[p2DefanderCardIndex].hp <= p1Damage) {
        //died.
        p2ActiveCards[p2DefanderCardIndex].hp = 0;
      } else {
        p2ActiveCards[p2DefanderCardIndex].hp -= p1Damage;
      }

      //####
      //buff damage.
      //####

      //####
      //life span hesaplama.
      //####

      //####
      //heal/poison hesaplamasi.
      //####


      //if aktifCard died. Recalculate.
      //iki oyuncunun kartlari da olduyse. (ayni islemleri tekrarlamamak icin.)
      if(p1ActiveCards[p1DefanderCardIndex].hp == 0 || p2ActiveCards[p1DefanderCardIndex].hp == 0) {
        
        if(p1ActiveCards[p1DefanderCardIndex].hp == 0) {

          p1Ap -= p1ActiveCards[p1DefanderCardIndex].ap;
          p1Sp -= p1ActiveCards[p1DefanderCardIndex].sp;
          p1Weight -= p1ActiveCards[p1DefanderCardIndex].weigth;
          p1Deff -= p1ActiveCards[p1DefanderCardIndex].deff;
          
          p1DeffFactor = _calculateDeffFactor(p1Deff);
        
          p1DefanderCardIndex++;
                  
        }

        if(p2ActiveCards[p1DefanderCardIndex].hp == 0) {

          p2Ap -= p2ActiveCards[p2DefanderCardIndex].ap;
          p2Sp -= p2ActiveCards[p2DefanderCardIndex].sp;
          p2Weight -= p2ActiveCards[p2DefanderCardIndex].weigth;
          p2Deff -= p2ActiveCards[p2DefanderCardIndex].deff;

          p2DeffFactor = _calculateDeffFactor(p2Deff);
        
          p2DefanderCardIndex++;
        }  

        weigthFactor = _calculateWeightFactor( p1Weight, p2Weight);
        p1Damage = _calculateDamage( p1Ap, p1Sp, weigthFactor, p2DeffFactor );
        p2Damage = _calculateDamage( p2Ap, p2Sp, weigthFactor, p1DeffFactor );

      }
      
      //kazanma kaybetme berabere durumlari
      //berabere
      if(p1DefanderCardIndex == 3 && p2DefanderCardIndex == 3) {

        return 3;
      //p1 winner
      } else if(p2DefanderCardIndex == 3) {

        return 1;
      //p2 winner
      } else if(p1DefanderCardIndex == 3) {

        return 2;
      }  

    }

    return 0;
  }
  
  //function _calculateGameState(uint256 _gameId, uint256 _time)
  function checkEndFinishGame(uint256 _gameId) public view returns(string){
    //TODO: Check gameId
    //todo: bu metod cagrilinca oyunu finishedgame'e koy.
    //cagirmada kontrol et. eger fnishedgames'de ise hesaplama yapma.
    uint256 gameState = _calculateGameState(_gameId, now);
    if(gameState == 0) {      
      return "oyun devam ediyor.";
      //hic birsey yapma. Masraf zamansiz cagirana girsin.
    } else if(gameState == 1) {
      //TODO: score guncelle.
      //kart random sec 2. oyuncudan ve 1. oyuncuya ver
      // ilk cagirana total escrow edilen etheri geri ver.
      return "1. oyuncu kazandi";    
    } else if(gameState == 2) {
      //TODO: score guncelle.
      //kart random sec 1. oyuncudan ve 2. oyuncuya ver
      //oyunu finishedgames'e koy.
      // ilk cagirana total escrow edilen etheri geri ver.
      return "2. oyuncu kazandi";    
    } else if(gameState == 3) {
      //TODO: score guncelle.
      //oyunu finishedgames'e koy.
      // ilk cagirana total escrow edilen etheri geri ver.
      return "Berabere.";    
    }

    //cagiran oyuncunun kartlarini geri ver.
    //yukaridaki return'lar test.
    return "buraya girmemesi lazim";
  }

  //oyun bulursa oyun baslatir
  //bulamaz ise siraya girer
  function startGameorEnterQueue(
    uint256 _card1, uint256 _card2, uint256 _card3, uint256 _card4,
    uint256 _card5, uint256 _card6, uint256 _card7, uint256 _card8
  ) public {
    //card'lari kontrol et.
    //TODO: cardid = 0 ise kullanilmiyor. passivecard'lar icin.
    require ( 
      nft.ownerOf(_card1) == address(msg.sender) &&
      nft.ownerOf(_card2) == address(msg.sender) &&
      nft.ownerOf(_card3) == address(msg.sender) &&
      nft.ownerOf(_card4) == address(msg.sender) &&
      (_card5 == 0 || nft.ownerOf(_card5) == address(msg.sender)) &&
      (_card6 == 0 || nft.ownerOf(_card6) == address(msg.sender)) &&
      (_card7 == 0 || nft.ownerOf(_card7) == address(msg.sender)) &&
      (_card8 == 0 || nft.ownerOf(_card8) == address(msg.sender))
    );
    
    Game1.Herd memory herd = Game1.Herd(msg.sender,
     _card1, _card2, _card3, _card4,
     _card5, _card6, _card7, _card8);

    _queueOrFindGame(herd);
  }


  function _queueOrFindGame(Game1.Herd _herd) internal {
    //oyuncu ilk kez oynuyor ise.
    //register yapmayi dusundum ama, her oyunda score olmayabilir.
    //sonra player olayini degistirebilirim.
    address player = _herd.owner;
    if(playersIndex[player] == 0) {
      playerScore[player] = NEW_PLAYER_SCORE;
    }

    int256 score = playerScore[player];
    int256 index = (score / SCORE_GAP) * SCORE_GAP; // kusurat atildi.
    bool gameFound;
    //not: else ifler icin score min max asimini kontrol etmeye gerek yok.
    // gamenot faund'da buralar icin hic bir zaman bir atama yapilmiyor.
    if(pendingGames[index].length > 0) {
      gameFound = true;
    } else if(pendingGames[index + SCORE_GAP].length > 0) {
      gameFound = true;
      index = index + SCORE_GAP;
    } else if(pendingGames[index - SCORE_GAP].length > 0) {
      gameFound = true;
      index = index - SCORE_GAP;
    }

    if(gameFound) {
      //sonuncuyu alsam? zaten bu kuyrugun dolmamasi lazim.
      //index her zaman > 0 burada (aslinda herzaman 1 oluyor)
      uint256 lastIndex = pendingGames[index].length - 1;
      Game1.Data game = pendingGames[index][lastIndex];

      pendingGames[index].length = pendingGames[index].length -1;
      delete pendingGames[index][lastIndex];

      //hizli erisim icin.
      game.id = numberOfGames;
      numberOfGames +=1; //id.
      game.player2 = player;
      game.herdOfPlayer2 = _herd;
      game.startTime = now;
      startedGames[game.id] = game;

      games.push(numberOfGames);
      myGames[game.player1].push(numberOfGames);
      myGames[game.player2].push(numberOfGames);

    } else {
      //note: struct olustururken null veremedigimiz icin hersey player1
      //starttime = created time for pending players.
      /*uint256 id;  //0 olabilir.
    address player1;
    address player2;
    uint256 startTime;
    Herd herdOfPlayer1;
    Herd herdOfPlayer2;    */
      Game1.Data memory newGame = Game1.Data(0, player, player, now, _herd, _herd);
      pendingGames[index].push(newGame);
    } 
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

function _addDevAccount(address _address, Role.RoleType _roleType, bool _active) internal returns(bool success) {
  if(!devAccounts[_address].active) {            
    devAccounts[_address].active = _active;
    devAccounts[_address].roleType = _roleType;
    devAccounts[_address].createdTime = "created Time";
    emit DevAccountRoleAdded(_address); //event'e role eklenebilir mi acaba?
    success = true;
  }
}

function addDevAccountToCEO (address _address, bool _active) __onlyOwner public returns(bool success) {
  success = _addDevAccount(_address, Role.RoleType.CEO, _active);     
}

function addDevAccountToCFO (address _address, bool _active) __onlyOwner public returns(bool success) {
  success = _addDevAccount(_address, Role.RoleType.CFO, _active);     
}

function addDevAccountToCOO (address _address, bool _active) __onlyOwner public returns(bool success) {
  success = _addDevAccount(_address, Role.RoleType.COO, _active);     
}

function removeDevAccount(address _address) __onlyOwner public returns(bool success) {
  if( devAccounts[_address].active ) {            
    devAccounts[_address].active = false;
    delete devAccounts[_address];
    emit DevAccountRoleRemoved(_address); //event'e role eklenebilir mi acaba?
    success = true;
  }
}

modifier __onlyCEO() {

  require(devAccounts[msg.sender].active);        
  require(devAccounts[msg.sender].roleType == Role.RoleType.CEO);
  _;
}

modifier __onlyCFO() {

  require(devAccounts[msg.sender].active);        
  require(devAccounts[msg.sender].roleType == Role.RoleType.CFO);
  _;
}

modifier __onlyCOO() {

  require(devAccounts[msg.sender].active);        
  require(devAccounts[msg.sender].roleType == Role.RoleType.COO);
  _;
}

modifier __OnlyForThisRoles1(bool _withOwner, Role.RoleType _role1 ) {
  bool result = false;
  if(_withOwner && isOwner()) {
    result = true;
  }
  if(devAccounts[msg.sender].active && devAccounts[msg.sender].roleType == _role1 ) {
    result = true;            
  }
  require (result);        
  _;
}

modifier __OnlyForThisRoles2(bool _withOwner, Role.RoleType _role1, Role.RoleType _role2 ) {
  bool result = false;
  if(_withOwner && isOwner()) {
    result = true;
  }
  if(devAccounts[msg.sender].active) {
    if( devAccounts[msg.sender].roleType == _role1 
      || devAccounts[msg.sender].roleType == _role2) {
      result = true;            
    }
  }
  require (result);        
  _;
}

modifier __OnlyForThisRoles3(bool _withOwner, Role.RoleType _role1, Role.RoleType _role2, Role.RoleType _role3 ) {
  bool result = false;
  if(_withOwner && isOwner()) {
    result = true;
  }
  if(devAccounts[msg.sender].active) {
    if( devAccounts[msg.sender].roleType == _role1 
      || devAccounts[msg.sender].roleType == _role2                 
      || devAccounts[msg.sender].roleType == _role3) {
      result = true;            
    }
  }
  require (result);        
  _;
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

contract UsingShareholder  {

using Shareholder for Shareholder.Data;
using Mutex for Mutex.Data;

event WithdrawOwnerBalance(address credit, uint256 amount);
event WithdrawShareholderBalance(address credit, uint256 amount);
mapping (address => Shareholder.Data) shareholderData;
address[] shareholders;
mapping (address => uint256) shareHoldersIndex;
mapping (address => address) ownerToPendingShareholders;
mapping (address => address) pendingShareholdersToOwner;

event ShareholderOwnershipTransferred(address previousOwner, address newOwner);

uint256 totalPercentage;
uint256 ownerBalance;

//for security
Mutex.Data mutex;

modifier __isOnlyOwnerOfShareholder() {
  require(shareholderData[msg.sender].owner == msg.sender);
  _;
}

function UsingShareholder() public payable{
  mutex = Mutex.Data(false);
  initShareHolders();
}

function initShareHolders() internal {
  // ilk hesaplar.   
  //initte total 100'u gecmemeli.

  address shareholderAddress1 = address(0x583031D1113aD414F02576BD6afaBfb302140225);
  _addShareHolder(shareholderAddress1, 10);

  address shareholderAddress2 = address(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
  _addShareHolder(shareholderAddress2, 20);
}

function isShareHolder(address _address) public view returns(bool) {
  if(shareholderData[_address].owner == _address) {
    return true;
  }
  return false;
}

function _addShareHolder(address _address, uint256 _percentage) internal {

  require (!isShareHolder(_address));

  uint nextTotalPercentage = totalPercentage + _percentage;
  if(nextTotalPercentage <= 100) {
    shareholderData[_address] = Shareholder.Data(_address, _percentage, 0);
    shareHoldersIndex[_address] = shareholders.length;
    shareholders.push(_address);
    totalPercentage = nextTotalPercentage;
  }                            
}   

//distributeBalance
function _distributeBalance(uint256 _amount) internal{
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
    // kontrolu _addShareHolder'da yapilmisti.
    ownerBalance += amount;
  }                
}

function _getOwnerBalance() internal view returns(uint256) {
  return ownerBalance;  
}

function _getShareholderBalance(address _address) internal view returns(uint256) {
  require(isShareHolder(_address));
  return shareholderData[_address].balance;  
}

function getOwnerOfShareholderBalance() __isOnlyOwnerOfShareholder public view returns(uint256) {
  return _getShareholderBalance(msg.sender);  
}


function withdrawShareholderBalance() __isOnlyOwnerOfShareholder public payable {
  mutex.enter();
  require(shareholderData[msg.sender].balance > 0); //belki mutex'e gerek kalmaz. Bu kontrol yetebilir.
  uint256 balance = shareholderData[msg.sender].balance;
  shareholderData[msg.sender].balance = 0;
  require(msg.sender.call.value(balance)());
  emit WithdrawShareholderBalance(msg.sender, balance);
  mutex.left();        
}

//TODO: bunun cagrildigi yer payable olmali.
function withdrawOwnerBalance() internal {
  mutex.enter();
  uint256 balance = ownerBalance;
  require(ownerBalance > 0); //belki mutex'e gerek kalmaz. Bu kontrol yetebilir.
  ownerBalance = 0;
  //TODO: sadece ownera gidecek. coe'ya degil.
  require(msg.sender.call.value(balance)());
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


contract A_PaniniController is PaniniDevAccounts, UsingShareholder {

  A_PaniniState paniniState;
  A_PaniniCard paniniCard;
  A_PaniniCardPackage paniniCardPackage;
  A_PaniniMarket paniniMarket;
  PaniniBase paniniBase; //Panini <--

  bool public isPaniniController = true;

  modifier __onlyIfPaniniBase{
    require (msg.sender == address(paniniBase));
    _;
  }

  modifier __onlyForAttachedPackages{
    require (msg.sender == address(paniniBase) ||
        msg.sender == address(paniniCard) ||
        msg.sender == address(paniniCardPackage) ||
        msg.sender == address(paniniMarket) );
    _;
  }


  modifier __whenNotPaused() {
    require(!paniniState.getPaused());
    _;
  }

  modifier __whenPaused() {
    require(paniniState.getPaused());
    _;
  }

  function isAttachedAll() __OnlyForThisRoles1(true, Role.RoleType.CEO) public view returns(bool) {
    if ( address(paniniState) != address(0) &&
      address(paniniCard) != address(0) &&
      address(paniniCardPackage) != address(0) &&
      address(paniniMarket) != address(0) &&
      address(paniniBase) != address(0) ) {
          return true;
      }
    return false;
  }

  function attachAll(address _paniniStateAddress,
    address _paniniCardAddress,
    address _paniniCardPackageAddress,
    address _paniniMarketAddress,
    address _paniniBaseAddress ) __OnlyForThisRoles1(true, Role.RoleType.CEO) public {

    require (!isAttachedAll());

    A_PaniniState candidatePaniniState = A_PaniniState(_paniniStateAddress);  
    A_PaniniCard candidatePaniniCard = A_PaniniCard(_paniniCardAddress);  
    A_PaniniCardPackage candidatePaniniCardPackage = A_PaniniCardPackage(_paniniCardPackageAddress);  
    A_PaniniMarket candidatePaniniMarket = A_PaniniMarket(_paniniMarketAddress);  
    PaniniBase candidatePaniniBase = PaniniBase(_paniniBaseAddress);  

    require ( 
      candidatePaniniState.isPaniniState() &&
      candidatePaniniCard.isPaniniCard() &&
      candidatePaniniCardPackage.isPaniniCardPackage() &&
      candidatePaniniMarket.isPaniniMarket() &&
      candidatePaniniBase.isPaniniBase());

    candidatePaniniState.attachA_PaniniController();
    candidatePaniniCard.attachA_PaniniController();
    candidatePaniniCardPackage.attachA_PaniniController();
    candidatePaniniMarket.attachA_PaniniController();
    candidatePaniniBase.attachA_PaniniController();

    candidatePaniniCard.setA_PaniniState(_paniniStateAddress);
    candidatePaniniCardPackage.setA_PaniniState(_paniniStateAddress);
    candidatePaniniMarket.setA_PaniniState(_paniniStateAddress);
    candidatePaniniBase.setA_PaniniState(_paniniStateAddress);

    candidatePaniniCardPackage.setA_PaniniCard(_paniniCardAddress);
    candidatePaniniBase.setA_PaniniCard(_paniniCardAddress);
    candidatePaniniBase.setA_PaniniCardPackage(_paniniCardPackageAddress);
    candidatePaniniBase.setA_PaniniMarket(_paniniMarketAddress);

    candidatePaniniMarket.setNFT(_paniniBaseAddress);

    paniniState = candidatePaniniState;
    paniniCard = candidatePaniniCard;
    paniniCardPackage = candidatePaniniCardPackage;
    paniniMarket = candidatePaniniMarket;
    paniniBase = candidatePaniniBase;
  }


  function distributeBalance(uint256 _amount) __onlyForAttachedPackages public {
    _distributeBalance(_amount);
  }
  
  function pause() __OnlyForThisRoles1(true, Role.RoleType.CEO) public returns (bool success) {
    paniniState.pause();
    success = true;            
  }

  function unPause() __OnlyForThisRoles1(true, Role.RoleType.CEO) public returns (bool success) {
    paniniState.unPause();
    success = true;
  }

  function addShareHolder(address _address, uint256 _percentage) __onlyOwner public {
    _addShareHolder(_address, _percentage);
  }

  function withdrawBalance() __OnlyForThisRoles1(true, Role.RoleType.CFO) public payable {
    withdrawOwnerBalance();
  }


  function getBalance() __OnlyForThisRoles1(true, Role.RoleType.CFO) public view returns(uint256) {
    return address(this).balance;  
  }

  function getOwnerBalance() __OnlyForThisRoles1(true, Role.RoleType.CFO) public view returns(uint256){
    return _getOwnerBalance();  
  }

  function getShareholderBalance(address _address) __OnlyForThisRoles1(true, Role.RoleType.CFO) public view returns(uint256) {
    return _getShareholderBalance(_address);  
  }
  
  
  function createCardBase(string _name, 
    uint256 _hp, uint256 _ap, uint256 _deff, uint256 _speed, uint256 _weigth, 
    uint256 _lifespan, uint256 _region, uint256 _rarity, uint256 _pasive, uint256 _pasivePercent ) __OnlyForThisRoles1(true, Role.RoleType.COO) public {
    paniniCard.createCardBase( _name, 
    _hp, _ap, _deff, _speed, _weigth, 
    _lifespan, _region, _rarity, _pasive, _pasivePercent );
  }
  


  function () public payable {

  }

}


/*
test: 2 tane contract var. bu contractlar PaniniBaseTest'in state'ini degistirmeye calisiyor.
//test sonucu: sadece A_PaniniControllerTest degistirebildi.
//sebebi: paninistate -> attachA_PaniniController
//not: sadece paniniController.attach yapmak yeterli.
*/

contract PaniniBaseTest is PaniniBase {

  function PaniniBaseTest() public payable {

  }

  //para dagitilacak.
  function distrubuteTest() public payable{
    require(address(paniniController).call.value(msg.value)());
    paniniController.distributeBalance(msg.value);        
  }


  function () public payable {

  }

}


contract PaniniControllerTest is A_PaniniController {

  function PaniniControllerTest() public payable{

  }
}


contract PaniniControllerWithOtherContractTest is A_PaniniController {

}