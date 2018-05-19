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
    require( self.isEntered == false);
    self.isEntered == true;    
  }

  function left(Mutex.Data self) pure internal {
    self.isEntered == false;    
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

  A_PaniniController paniniController;

  modifier __onlyIfA_PaniniController {
    require (msg.sender == address(paniniController));
    _;
  }

  //1 kere set edilebilsin
  function attachA_PaniniController(address _address) public {
    //if(address(paniniController) == address(0) && _address != address(0) ) {
      paniniController = A_PaniniController(_address);
    //}      
  }

}

contract A_PaniniState is AttachingA_PaniniController {

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

/**
 * The HasA_PaniniState contract does this and that...
 */
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
  function setA_PaniniState(address _address) public {
    //if(address(paniniState) == address(0) && _address != address(0) ) {
      paniniState = A_PaniniState(_address);
    //}      
  }

  function testA_PaniniState() public view returns(bool) {
    return paniniState.getPaused();
  }
  
}



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

  //returns clone of base card.
  function toTuple(AnimalCardBase.Data self) internal pure returns(uint256, string, uint256, uint256, uint256, uint256, uint256) {

    uint256 regionIndex = 1; //default ASIA
    if(self.region == Region.AFRICA) {
      regionIndex = 2;
    } else if(self.region == Region.NOURTH_AMERICA) {
      regionIndex = 3;
    } else if(self.region == Region.SOUTH_AMERICA) {
      regionIndex = 4;
    } else if(self.region == Region.ANTARCTICA) {
      regionIndex = 5;
    } else if(self.region == Region.EUROPE) {
      regionIndex = 6;
    } else if(self.region == Region.AUSTRALIA) {
      regionIndex = 7;
    } else if(self.region == Region.OCEAN) {
      regionIndex = 8;
    }
    return (self.id, self.name, self.health, self.weigth, self.speed, regionIndex, self.rarity);
  }

  function fromTuple(AnimalCardBase.Data self, uint256 _id, string _name, uint256 _health, uint256 _weigth, uint256 _speed, uint256 _regionIndex, uint256 _rarity) internal pure {

      self.id = _id;
      self.name = _name;
      self.health = _health;
      self.weigth = _weigth;
      self.speed = _speed;

      self.region = Region.ASIA;
      if(_regionIndex == 2) {
        self.region = Region.AFRICA;  
      } else if(_regionIndex == 3) {
        self.region = Region.NOURTH_AMERICA;  
      } else if(_regionIndex == 4) {
        self.region = Region.SOUTH_AMERICA;  
      } else if(_regionIndex == 5) {
        self.region = Region.ANTARCTICA;  
      } else if(_regionIndex == 6) {
        self.region = Region.EUROPE;  
      } else if(_regionIndex == 7) {
        self.region = Region.AUSTRALIA;  
      } else if(_regionIndex == 8) {
        self.region = Region.OCEAN;  
      }

      self.rarity = _rarity;
  }

}

/**
 * The A_PaniniCardBase contract does this and that...
 */
 contract A_PaniniCardBase is AttachingA_PaniniController, HasA_PaniniState {
  using AnimalCardBase for AnimalCardBase.Data;

  //server tarafinda her create'te db guncellenecek. Bu sayede base card'larin listesi goruntulenebilecek.
  event CreatedAnimalCard(uint256 id, string name, uint256 health, uint256 weigth, uint256 speed, uint256 regionIndex, uint256 rarity);
  // metedata
  AnimalCardBase.Data[] animalCardBaseList; 

  function A_PaniniCardBase () public {
    initAnimalCardBase();
  }  

  function initAnimalCardBase() internal {
       //id'lerin indexler ile ayni olmasi icin eklendi. Kullanilmayacak. bunun id'si 0.
        _createAnimalCardBase('empty', 0, 0, 0, AnimalCardBase.Region.AFRICA, 0 );        
        
        _createAnimalCardBase('fil', 1000, 3000, 60, AnimalCardBase.Region.AFRICA, 14 );        
        _createAnimalCardBase('at', 400, 500, 90, AnimalCardBase.Region.ASIA, 22 );        
        _createAnimalCardBase('tavsan', 20, 2, 80, AnimalCardBase.Region.EUROPE, 55 );        
        _createAnimalCardBase('aslan', 200, 200, 80, AnimalCardBase.Region.AFRICA, 21 );        

        _createAnimalCardBase('balina', 10000, 30000, 40, AnimalCardBase.Region.OCEAN, 14 );        
        _createAnimalCardBase('yunus', 1000, 300, 80, AnimalCardBase.Region.OCEAN, 25 );        
        _createAnimalCardBase('kilic baligi', 100, 40, 140, AnimalCardBase.Region.OCEAN, 5 );        

        _createAnimalCardBase('kartal', 100, 15, 100, AnimalCardBase.Region.ASIA, 25 );        
        _createAnimalCardBase('guvercin', 10, 1, 30, AnimalCardBase.Region.SOUTH_AMERICA, 24 );        

        _createAnimalCardBase('karinca', 1, 1, 1, AnimalCardBase.Region.EUROPE, 43 );            

  }

  // usuable id between 1 to (n-1)
  function existAnimalCardBase(uint256 _baseId ) public view returns(bool) {
    if( _baseId > 0 && _baseId <= animalCardBaseList.length) {
      return true;
    }
    return false;                
  }

  //usuable card id starts with 1.
  function _createAnimalCardBase(string _name, uint256 _health, uint256 _weigth, uint256 _speed, AnimalCardBase.Region _region, uint256 _rarity ) internal{
    uint256 id = animalCardBaseList.length;
    animalCardBaseList.push(AnimalCardBase.Data(id, _name, _health, _weigth, _speed, _region, _rarity));
  }

  // usuable card id starts with 1.
  // __onlyIfA_PaniniController
  function createAnimalCardBase(string _name, uint256 _health, uint256 _weigth, uint256 _speed, uint256 _regionIndex, uint256 _rarity ) __onlyIfA_PaniniController public {
    AnimalCardBase.Region region = AnimalCardBase.Region.ASIA;
    if(_regionIndex == 2) {
      region = AnimalCardBase.Region.AFRICA;  
    } else if(_regionIndex == 3) {
      region = AnimalCardBase.Region.NOURTH_AMERICA;  
    } else if(_regionIndex == 4) {
      region = AnimalCardBase.Region.SOUTH_AMERICA;  
    } else if(_regionIndex == 5) {
      region = AnimalCardBase.Region.ANTARCTICA;  
    } else if(_regionIndex == 6) {
      region = AnimalCardBase.Region.EUROPE;  
    } else if(_regionIndex == 7) {
      region = AnimalCardBase.Region.AUSTRALIA;  
    } else if(_regionIndex == 8) {
      region = AnimalCardBase.Region.OCEAN;  
    }
    _createAnimalCardBase(_name, _health, _weigth, _speed, region, _rarity);
  }

  //returns index of animalCardBase
  function generateRandomBaseId(uint256 random) public view returns (uint256) {
    //private test for random
    uint256 id = animalCardBaseList.length;
    uint256 delta = animalCardBaseList.length;
    require(delta > 0);

    id = (  random  * ( id + 2 ) * ( 3 * id + 2 ) ) % delta;
    return id;

    // random'u nasil yapacagiz buna karar verilecek.
    //kartlar eklenirken bir islem yapilacak. random card genereate ederken secim buna gore. bir array'den index cikartilacak.
  }

  function getAnimalCardBaseTupple(uint256 _baseId) public view returns(uint256, string, uint256, uint256, uint256, uint256, uint256) {
    require( _baseId > 0 && _baseId <= animalCardBaseList.length);
    return animalCardBaseList[_baseId].toTuple();
  }
  
}



contract A_PaniniCardPackage is AttachingA_PaniniController, HasA_PaniniState {
 
  event PackageCreated(uint256 id, address receiver, uint256 baseId1, uint256 baseId2, uint256 baseId3, uint256 baseId4, uint256 baseId5 );

  struct PackagePrice{
    uint256 normal;
    uint256 initial;
    uint256 special;
  }

  A_PaniniCardBase paniniCardBase;

  uint256 numberOfPackageCreated;

  //package gecmisi tutulacak mi?    
  PackagePrice packagePrice;

  function A_PaniniCardPackage () public{
    packagePrice.normal = 5000000000000000000; //0.05 ether
    packagePrice.initial = 1000000000000000000; //0.01 ether
    packagePrice.special = 3000000000000000000; //0.03 ether
  }  

  //1 kere set edilebilsin
  function setA_PaniniCardBase(address _address) public {
    //if(address(paniniCardBase) == address(0) && _address != address(0) ) {
      paniniCardBase = A_PaniniCardBase(_address);
    //}      
  }

  function createPackage(address _address) public view returns(uint256, uint256, uint256, uint256, uint256){
    numberOfPackageCreated += 1; //ayni zamanda package id.
    uint256 packageId = numberOfPackageCreated;

    //generating cards bases
    uint256 baseId1 = paniniCardBase.generateRandomBaseId(numberOfPackageCreated);
    uint256 baseId2 = paniniCardBase.generateRandomBaseId(numberOfPackageCreated * baseId1);
    uint256 baseId3 = paniniCardBase.generateRandomBaseId(numberOfPackageCreated * baseId2);
    uint256 baseId4 = paniniCardBase.generateRandomBaseId(numberOfPackageCreated * baseId3);
    uint256 baseId5 = paniniCardBase.generateRandomBaseId(numberOfPackageCreated * baseId4);
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



contract A_PaniniMarket is AttachingA_PaniniController, HasA_PaniniState {
  using Auction for Auction.Data;

  event CreateAuction(address owner, uint256 _cardId, uint256 _startPrice, uint256 _endPrice, uint256 _duration);
  event CancelAuction(address owner, uint256 _cardId);
  event Bid(address owner, address sender, uint256 _cardId, uint256 amount);

  // Values 0-10,000 map to 0%-100%
  uint256 public ownerCut;

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
  PaniniERC721Token public nft; // panini

  function A_PaniniMarket() public {
  }

    //TODO: 1 kez set edilecek sekilde degistirilecek.
  function setNFT(address _address) public {
    //if(address(nft) == address(0) && _address != address(0) ) {
      nft = PaniniERC721Token(_address);
    //}
  }

  //TODO: 1 kez set edilecek sekilde degistirilecek.
  function setCut(uint256 _cut) public {
    if(ownerCut == 0 && _cut != 0 ) {
      ownerCut = _cut;
    }
  }
  
  function getOwnerCut() public view returns(uint256) {
    return ownerCut;
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
    //TODO CHECK: owner + cardid.
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

  A_PaniniCardBase paniniCardBase;
  A_PaniniCardPackage paniniCardPackage;
  A_PaniniMarket paniniMarket;

  //for security
  Mutex.Data mutex;

  function PaniniBase() public{
    mutex = Mutex.Data(false);

  }  

  //1 kere set edilebilsin
  function setA_PaniniCardBase(address _address) public {
    //if(address(paniniCardBase) == address(0) && _address != address(0) ) {
      paniniCardBase = A_PaniniCardBase(_address);
    //}      
  }

  //1 kere set edilebilsin
  function setA_PaniniCardPackage(address _address) public {
    //if(address(paniniCardPackage) == address(0) && _address != address(0) ) {
      paniniCardPackage = A_PaniniCardPackage(_address);
    //}      
  }

  //1 kere set edilebilsin
  function setA_PaniniMarket(address _address) public {
    //if(address(paniniMarket) == address(0) && _address != address(0) ) {
      paniniMarket = A_PaniniMarket(_address);
      //TODO: 1 kere set edilebilsin bu methodlar.
      paniniMarket.setNFT(address(this));
      paniniMarket.setCut(1000); //%10
      
    //}      
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
    uint256 baseId = paniniCardBase.generateRandomBaseId(lastMintedCardId);
    //kart'in uretilmesi.
    return _mintCardWithBaseId(_to, baseId);
  }
/*
  function getAnimalCardInfo(uint256 _cardId) public view returns(uint256, string, uint256, uint256, uint256, uint256, uint256) {
    uint256 baseId = cardIdToBaseId[_cardId];
    if(baseId != 0) {
      return paniniCardBase.getAnimalCardBaseTupple(baseId);
    }    
    return (0,'0',0,0,0,0,0);
  }
*/
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

//#########################################
//###            PLAYERS                ###
//#########################################
//server'da register.
//bir liste tut serverda
library Player{

  struct Data {
    uint256 id; 
    string name;
    uint256 numberOfStars;

    //server'da tutulacak. 
    //TODO: nasil goruntuleyecek? nasil serverda tutulacak?
    // emit (address, cardId, baseId)?
    //baseId -> cardIndex-tokenId
//    mapping(uint256 => uint256[]) animalCards;
    //cardId -> index of animalCards[baseId]
//    mapping(uint256 => uint256) animalCardsIndex;    
  }
}

//TODO: approve'du vs bunun gibi metodlara bir el atilacak.
// sebep: mesela bir kart'i auction'a koydu. contract'i approve edilmektedir.
//   daha sonra disaridan bu approve'yi kaldirirsa, kendi listesinde kart gozukmeyecek.
//  Ve ne bid islemi ne de cancel islemi gerceklestirilemeyecektir.
contract UsingPlayer is UsingCard{
  using Player for Player.Data;
  mapping (address => Player.Data) players;
  uint256 numberOfPlayer;

  function UsingPlayer() public {

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
function bid(uint256 _cardId, uint256 _amount) __isPlayer __whenNotPaused public payable{
  mutex.enter();

  uint256 currentPrice = paniniMarket.computeCurrentPrice(_cardId);
  require (currentPrice == msg.value);

  paniniMarket.bid(msg.sender, _cardId, _amount);

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
  mutex.left();
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

    //TODO: numberOfStars calculation function.

  }

  //#########################################
  //###             PANINI                ###
  //#########################################
  contract A_Panini is UsingPlayer{

    function A_Panini() public {

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
  if( devAccounts[_address].active == false ) {            
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
  PaniniBase paniniBase; //Panini <--
  A_PaniniCardBase paniniCardBase;
  A_PaniniCardPackage paniniCardPackage;
  A_PaniniMarket paniniMarket;
 
  modifier __onlyIfPaniniBase{
    require (msg.sender == address(paniniBase));
    _;
  }

  modifier __onlyForAttachedPackages{
    require (msg.sender == address(paniniBase) ||
        msg.sender == address(paniniCardBase) ||
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

  //1 kez set edilebilsin.
  function attachPaniniBase(address _address) public {
    //if( address(paniniState) == address(0) && _address != address(0) ) {
      paniniBase = PaniniBase(_address);       
      paniniBase.attachA_PaniniController(address(this));
    //}
  }
  
  //1 kez set edilebilsin.
  function attachA_PaniniState(address _address) public {
    //if( address(paniniState) == address(0) && _address != address(0) ) {
      paniniState = A_PaniniState(_address);       
      paniniState.attachA_PaniniController(address(this));
    //}
  }

  //1 kez set edilebilsin.
  function attachA_PaniniCardBase(address _address) public {
    //if( address(paniniCardBase) == address(0) && _address != address(0) ) {
      paniniCardBase = A_PaniniCardBase(_address);       
      paniniCardBase.attachA_PaniniController(address(this));
    //}
  }
  //1 kez set edilebilsin.
  function attachA_PaniniCardPackage(address _address) public {
    //if( address(paniniMarket) == address(0) && _address != address(0) ) {
      paniniCardPackage = A_PaniniCardPackage(_address);       
      paniniCardPackage.attachA_PaniniController(address(this));
    //}
  }
  
  //1 kez set edilebilsin.
  function attachA_PaniniMarket(address _address) public {
    //if( address(paniniMarket) == address(0) && _address != address(0) ) {
      paniniMarket = A_PaniniMarket(_address);       
      paniniMarket.attachA_PaniniController(address(this));
    //}
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
  
  function createAnimalCardBase(string _name, uint256 _health, uint256 _weigth, uint256 _speed, uint256 _regionIndex, uint256 _rarity ) __OnlyForThisRoles1(true, Role.RoleType.COO) public {
    paniniCardBase.createAnimalCardBase(_name, _health, _weigth, _speed, _regionIndex, _rarity );
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