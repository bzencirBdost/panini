pragma solidity 0.4.21;
//run : remix-ide
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


contract AttachingAX_PaniniController {
  using AddressUtils for address;
  
  AX_PaniniController paniniController;

  modifier __onlyIfAX_PaniniController {
    require (msg.sender == address(paniniController));
    _;
  }

  //1 kere set edilebilsin
  //msg.sender bir contract olmali.
  //msg.sender paniniController olmali.
  function attachAX_PaniniController() public {    
    require(address(paniniController) == address(0));
    require (msg.sender.isContract() );    
    AX_PaniniController candidatePaniniController = AX_PaniniController(msg.sender);
    //require (paniniController.isPaniniController());   
    paniniController = candidatePaniniController;      
  }

}

contract A_PaniniState is AttachingAX_PaniniController {

  bool public isPaniniState = true;

  bool paused;
  uint256 presaledEndDate;

  event Pause();
  event UnPause();

  function A_PaniniState() public {
  }

  function kill() public  {
    selfdestruct(msg.sender);
  }

  function getPaused() public view returns(bool) {
    return paused;
  }

  function pause() __onlyIfAX_PaniniController public {
    paused = true;
  }

  function unPause() __onlyIfAX_PaniniController public {
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


/* gerek yok artik buna. -> bitwise operations..
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

}*/

/**
 * The A_PaniniCard contract does this and that...
 */
 contract A_PaniniCard is AttachingAX_PaniniController, HasA_PaniniState {

  bool public isPaniniCard = true;
  //server tarafinda her create'te db guncellenecek. Bu sayede base card'larin listesi goruntulenebilecek.
  event CreatedAnimalCard(uint256 metedata );

  // metedata
  uint256[] metadatas; 
  //card indexs with rarity
  mapping(uint256 => uint256[]) rarityIndexs; //1 common, 2 rare, 3 exotic
  
  function A_PaniniCard () public {
    initCardBase();
  }  

  function kill() public  {
    selfdestruct(msg.sender);
  }

  function initCardBase() internal {
    //id'lerin indexler ile ayni olmasi icin eklendi. Kullanilmayacak. bunun id'si 0.
    _createCardBase(0); 
    _createCardBase(0x110000000000000640000000000000032000050000c800032000be0001a);
    _createCardBase(0x1100000000032000000000000000000050000140001400018000060000e);
    _createCardBase(0x31000000000000000000000780000000960001e000320004b0025800013);
    _createCardBase(0x21000000000000000005000000000003e8000320012c00023004b000011);
    _createCardBase(0x3100000000000000000000000280000258000500009600028000dc0000f);
    _createCardBase(0x31000000000000000000000500000000640003c00032000960000700012);
    _createCardBase(0x101000000003c000000000000000000014000050000a000400000100012);
    _createCardBase(0x101000000000000500000000000000001e0001e0001e000110000100016);
    _createCardBase(0x1001000000000000000003c000000000c80000a00064000520012c0000f);
    _createCardBase(0x10010000028000000000000000000000320002800032000030000100018);
    _createCardBase(0x10010000000000000000000003c00000fa00046000960004b000200000c);
    _createCardBase(0x20001000000000000000000780000000fa0005a0005000070000300000b);
    _createCardBase(0x200010000000000003c00000000000015e0006e000780003c0004d00018);
    _createCardBase(0x2000100000000003c000000000000006400003c000640002d009c40002d);
    _createCardBase(0x30001000000000064000000000000003e800064001900002a0044c0002f);
    _createCardBase(0x200010000280000000000000000000000a000280000a00005000020000b);
    _createCardBase(0x300001000003c00000000000000000012c0000a0012c00020000b400020);
    _createCardBase(0x30000100000000000006400000000006a400078001f40002b00fa000043);
    _createCardBase(0x200001000320000000000000000000003c0003200032000070000500012);
    _createCardBase(0x30000010000000050000000000000000780003200050000180000700007);
    _createCardBase(0x100000100000000000000000000c8000c80001400064000370004100007);
    _createCardBase(0x30000010000320000000000000000000140000a0000a000020000800012);
    _createCardBase(0x100000010000000000000000000960025800014000c8000130070800013);
    _createCardBase(0x30000000100000000000000002800005780005a000640002c01d4c00038);
    _createCardBase(0x20000000100000000640000000000003200005000064000180067200026);
  }

  // usuable id between 1 to (n-1)
  function existCardBase(uint256 _baseId) public view returns(bool) {
    if( _baseId > 0 && _baseId <= metadatas.length) {
      return true;
    }
    return false;                
  }

  // usuable id between 1 to (n-1)
  function getMetadataFromBaseId(uint256 _baseId) public view returns(uint256) {
    if( _baseId > 0 && _baseId <= metadatas.length) {
      return metadatas[_baseId];
    }
  }

  //usuable card id starts with 1.
  function _createCardBase(uint256 _metedata ) internal{
    uint256 rarity = (_metedata >> 232) & 255;
    rarityIndexs[rarity].push(metadatas.length);

    metadatas.push(_metedata);
  }

  // usuable card id starts with 1.
  // __onlyIfAX_PaniniController
  function createCardBase(uint256 _metedata ) __onlyIfAX_PaniniController public {
    _createCardBase(_metedata );
  }

  function randomToRarity(uint256 _random) public pure returns (uint256) {
    
    if((_random % 100) < 70) {
      return 1;
    }    
    if((_random % 100) < 90) {
     return 2;
    }
    return 3;
  }


  function randomToBaseIdByRarity(uint256 _random, uint256 _rarity) public view returns (uint256) {
    //index of metedata
    return _random % rarityIndexs[_rarity].length;
  }

  // function randomToBaseId(uint256 _random) public view returns (uint256) {
  //   return randomToBaseIdByRarity(_random, randomToRarity(_random));
  // }

}


contract A_PaniniCardPackage is AttachingAX_PaniniController, HasA_PaniniState {
 
  event PackageCreated(uint256 id, address receiver, uint256 baseId1, uint256 baseId2, uint256 baseId3, uint256 baseId4, uint256 baseId5 );

  struct PackagePrice {
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

  function kill() public  {
    selfdestruct(msg.sender);
  }

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniCard(address _address) __onlyIfAX_PaniniController public {    
    require(address(paniniCard) == address(0) && _address != address(0) );
    paniniCard = A_PaniniCard(_address);         
  }

  function createPackage(address _address) public returns(uint256, uint256, uint256, uint256, uint256) {
    
    //generating cards bases
    uint256[] memory baseIds = new uint256[](6);
    numberOfPackageCreated += 1; //ayni zamanda package id.
    baseIds[5] = numberOfPackageCreated;//packageId

    //NOTE-1: zamana, kisiye ve isleme bagli degisim var. Bu sayede;
    // farkli zamanlarda farkli kartlar uretilecektir(ayni kisi ve islem icin.).
    // farkli islemlerde farkli kartlar uretilecektir.(ayni kisi ve ayni zaman dilimi icin.).
    // farki kisiler icin farkli kartlar uretilecektir.(ayni zaman dilimi ve ayni islem icin.).
    //NOTE-2: 250 block yaklasik 1 saat yapmakta. Bu sayede brute force ile paket secmek oldukca zahmetli.
    uint256[] memory rnd = new uint256[](4); //last index: random
    rnd[1] = uint256(keccak256(_address))%1000000; //kisiye bagli degisim
    rnd[2] = uint256(keccak256(baseIds[5]))%1000000; //isleme bagli degisim
    rnd[3] = uint256(keccak256(block.blockhash( (block.number/250 )*250 )))%1000000;//zamana bagli degisim
    
    rnd[2] = 0;//rare count
    rnd[3] = 0; //epic count

    //1. card
    rnd[0] = uint256(keccak256(rnd[1] * rnd[2] * rnd[3]))%1000000000; 
    rnd[1] = paniniCard.randomToRarity(rnd[0]);//rarity
    rnd[rnd[1]] += 1; //epic or rare count ++
    baseIds[0] = paniniCard.randomToBaseIdByRarity(rnd[0], rnd[1]);
  
    //2. card
    rnd[0] = uint256(keccak256(baseIds[0] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToRarity(rnd[0]);//rarity
    if(rnd[1] == 3 && (rnd[3] == 1) ) {//if has exotic and new card is exotic
      rnd[1] = 2;  
    }
    if(rnd[1] == 2 && (rnd[3] + rnd[2] == 2) ) {//if has 2 exo/rary card and new card is rare
      rnd[1] = 1;  
    }
    if(rnd[1] != 1) {
      rnd[rnd[1]] += 1; //epic or rare count ++
    }
    baseIds[1] = paniniCard.randomToBaseIdByRarity(rnd[0], rnd[1]);

    //3. card
    rnd[0] = uint256(keccak256(baseIds[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToRarity(rnd[0]);//rarity
    if(rnd[1] == 3 && (rnd[3] == 1) ) {//if has exotic and new card is exotic
      rnd[1] = 2;  
    }
    if(rnd[1] == 2 && (rnd[3] + rnd[2] == 2) ) {//if has 2 exo/rary card and new card is rare
      rnd[1] = 1;  
    }
    if(rnd[1] != 1) {
      rnd[rnd[1]] += 1; //epic or rare count ++
    }
    baseIds[2] = paniniCard.randomToBaseIdByRarity(rnd[0], rnd[1]);

    //4. card
    rnd[0] = uint256(keccak256(baseIds[2] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToRarity(rnd[0]);//rarity
    if(rnd[1] == 3 && (rnd[3] == 1) ) {//if has exotic and new card is exotic
      rnd[1] = 2;  
    }
    if(rnd[1] == 2 && (rnd[3] + rnd[2] == 2) ) {//if has 2 exo/rary card and new card is rare
      rnd[1] = 1;  
    }
    if(rnd[1] != 1) {
      rnd[rnd[1]] += 1; //epic or rare count ++
    }
    baseIds[3] = paniniCard.randomToBaseIdByRarity(rnd[0], rnd[1]);

    //5. card
    //eger hic rare/exo card cikmamis ise 1 tane rare ver.
    rnd[0] = uint256(keccak256(baseIds[3] * rnd[0]))%1000000000;
    if(rnd[3] + rnd[1] == 0) {
      baseIds[4] = paniniCard.randomToBaseIdByRarity(rnd[0], 2);
    } else {
      rnd[1] = paniniCard.randomToRarity(rnd[0]);//rarity
      if(rnd[1] == 3 && (rnd[3] == 1) ) {//if has exotic and 2.card is exotic
        rnd[1] = 2;  
      }
      if(rnd[1] == 2 && (rnd[3] + rnd[2] == 2) ) {//if has 2 exo/rary card and new card is rare
        rnd[1] = 1;  
      }
      if(rnd[1] != 1) {
        rnd[rnd[1]] += 1; //epic or rare count ++
      }
      baseIds[4] = paniniCard.randomToBaseIdByRarity(rnd[0], rnd[1]);
    }


    emit PackageCreated(baseIds[5], _address, baseIds[0], baseIds[1], baseIds[2], baseIds[3], baseIds[4]);
    return (baseIds[0], baseIds[1], baseIds[2], baseIds[3], baseIds[4]);
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

contract A_PaniniMarket is AttachingAX_PaniniController, HasA_PaniniState, ERC721Receiver {
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

  function kill() public  {
    selfdestruct(msg.sender);
  }
  
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4) {
    return ERC721_RECEIVED;
  }

  //TODO: 1 kez set edilecek sekilde degistirilecek.
  //sadece paniniController set edebilsin.
  function setNFT(address _address) __onlyIfAX_PaniniController public {  
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
 contract PaniniBase is AttachingAX_PaniniController, HasA_PaniniState {
  using Mutex for Mutex.Data;

  bool public isPaniniBase = true;

  A_PaniniCard paniniCard;
  A_PaniniCardPackage paniniCardPackage;
  A_PaniniMarket paniniMarket;
  A_PaniniGameCore gameCore;

  //for security
  Mutex.Data mutex;

  function PaniniBase() public{
    mutex = Mutex.Data(false);

  }  

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniCard(address _address) __onlyIfAX_PaniniController public {    
    require(address(paniniCard) == address(0) && _address != address(0) );
    paniniCard = A_PaniniCard(_address);         
  }

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniCardPackage(address _address) __onlyIfAX_PaniniController public {
    require(address(paniniCardPackage) == address(0) && _address != address(0) );
    paniniCardPackage = A_PaniniCardPackage(_address);
  }

  //1 kere set edilebilsin
  //sadece paniniController'dan set edilebilsin.
  function setA_PaniniMarket(address _address) __onlyIfAX_PaniniController public {
    require(address(paniniMarket) == address(0) && _address != address(0) );
    paniniMarket = A_PaniniMarket(_address);
  }

  //UsingCard Methods
   function getCard(uint256 _cardId) public view returns(uint256) {}


  //Panini Methods
  function setA_PaniniGameCore(address _address) __onlyIfAX_PaniniController public {}


}




contract UsingCard is PaniniBase, PaniniERC721Token {
  //ANIMAL CARDS
  // Bu deger her card uretildiginde emit ile server tarafinda tutulacak. Ve arayuzde oradan gosterilecek.
  //mapping (uint256 => uint256[]) baseIdToCardIdList;

  uint256 mintedCardCount; // listeye gerek yok. eger liste olsaydı su sekilde olacaktı [0,1,2,3,4,5,6..n]  
  mapping (uint256 => uint256) cards;//card+metadata
  //token generate etmek icin;
  

  function UsingCard() public {

  }
  
  function _upgradeCard(uint256 _cardId, uint256 _burnedCardId) internal {

    uint256[] memory cardArr = new uint256[](3);
    uint256[] memory rarities = new uint256[](2);

    //cart'lar ayni cart olmamali
    require( _cardId != _burnedCardId );

    cardArr[1] = getCard(_cardId);
    cardArr[0] = paniniCard.getMetadataFromBaseId(cardArr[1] >> 240);
    cardArr[2] = getCard(_burnedCardId);
    //cart'lar var mi
    require( (cardArr[0] != 0) && (cardArr[1] != 0) );
    //lvl check. max 10
    require( (cardArr[1]>>236) < 10);

    //rarities.
    rarities[0] = (cardArr[1] >> 232) & 15;
    rarities[1] = (cardArr[2] >> 232) & 15;

    if(rarities[0] == 1) { //common 1

      //check same rarity
      require(rarities[1] == 1);
      //lvl check. same lvl
      require( (cardArr[1] >> 236 ) == ( cardArr[2] >> 236 ) );

    } else if(rarities[0] == 2) { //rare 2

      //ayni rarity ise
      if(rarities[0] == rarities[1]) {
        //lvl check. same lvl
        require( (cardArr[1] >> 236 ) == ( cardArr[2] >> 236 ) );      
      } else {
        
        require(rarities[1] == 1);//yakilan common olmak zorunda.
        //common lvl i+1 olmali.
        require(((cardArr[1] >> 236 ) + 1 ) == ( cardArr[2] >> 236 ) );      
      }

    } else { //exotic 3

      require(rarities[0] == 3);//nolur nolmaz. exotic mi kontrol et.

      //ayni rarity ise
      if(rarities[0] == rarities[1]) {
        //lvl check. same lvl
        require( (cardArr[1] >> 236 ) == ( cardArr[2] >> 236 ) );      
      } else {
        
        require(rarities[1] == 2);//yakilan rare olmak zorunda.
        //rare lvl i+1 olmali.
        require(((cardArr[1] >> 236 ) + 1 ) == ( cardArr[2] >> 236 ) );      
      }
    }

    //check is owner of card.
    require( ownerOf(_cardId) == msg.sender && ownerOf(_burnedCardId) == msg.sender ); 
    _burn(msg.sender, _burnedCardId );
    cards[_burnedCardId] = 0; //cards'tan sil.

    //calc. %10 val of stats.
    //main stats.
    cardArr[2] = 0;//reset
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 100 ) & 1048575))/10) <<100); //hp
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 80 ) & 1048575))/10) <<80); //ap
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 60 ) & 1048575))/10) <<60); //deff
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 40 ) & 1048575))/10) <<40); //speed
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 20 ) & 1048575))/10) <<20); //weight

    //buffs. 1 to 10
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 192 ) & 255))/10) <<192); //buff1
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 184 ) & 255))/10) <<184); //buff2
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 176 ) & 255))/10) <<176); //buff3
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 168 ) & 255))/10) <<168); //buff4
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 160 ) & 255))/10) <<160); //buff5
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 152 ) & 255))/10) <<152); //buff6
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 144 ) & 255))/10) <<144); //buff7
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 136 ) & 255))/10) <<136); //buff8
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 128 ) & 255))/10) <<128); //buff9
    cardArr[2] = cardArr[2] | (((((cardArr[0] >> 120 ) & 255))/10) <<120); //buff10

    //++lvl
    cardArr[2] = 1 << 236;
    cards[_cardId] = cardArr[1] + cardArr[2];
  }

  //cart üretilmesi için.
  //token kullanacak.
  //to: token icin. 
  //baseId: random generated value of basecard index. 
  //metadata -> card
  function _mintCardWithBaseId(address _to, uint256 _baseId) internal returns(uint256){
    
    mintedCardCount++;
    uint256 cardId = mintedCardCount;
    super._mint(_to, cardId);
    // set baseId of metedata
    //meteData'nin alinmasi
    uint256 metedata = paniniCard.getMetadataFromBaseId(_baseId);
    //0xFFFF0000000000000000000000000000000000000000000000000000000000000//baseid
    //0x    F000000000000000000000000000000000000000000000000000000000000//lvl
    cards[cardId] = (_baseId << 240)
      //0 olsun ilk lvl. 
      | (metedata);
    return cards[cardId];
  }
  
  //1 rare, 9 normal card.
  function _mintNewPlayerCards(address _to) internal {

    //NOTE-1: zamana, kisiye ve isleme bagli degisim var. Bu sayede;
    // farkli zamanlarda farkli kartlar uretilecektir(ayni kisi ve islem icin.).
    // farkli islemlerde farkli kartlar uretilecektir.(ayni kisi ve ayni zaman dilimi icin.).
    // farki kisiler icin farkli kartlar uretilecektir.(ayni zaman dilimi ve ayni islem icin.).
    //NOTE-2: 250 block yaklasik 1 saat yapmakta. Bu sayede brute force ile paket secmek oldukca zahmetli.
    uint256[] memory rnd = new uint256[](4); //last index: random
    rnd[1] = uint256(keccak256(_to))%1000000; //kisiye bagli degisim
    rnd[2] = uint256(keccak256(mintedCardCount))%1000000; //isleme bagli degisim
    rnd[3] = uint256(keccak256(block.blockhash( (block.number/250 )*250 )))%1000000;//zamana bagli degisim

    //1. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[2] * rnd[3]))%1000000000; 
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1); //baseid -> common
    _mintCardWithBaseId(_to, rnd[1]);

    //2. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);

    //3. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);

    //4. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);

    //5. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);

    //6. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);
    
    //7. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);
    
    //8. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);
    
    //9. card    
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 1);
    _mintCardWithBaseId(_to, rnd[1]);

    //10 card: rare
    rnd[0] = uint256(keccak256(rnd[1] * rnd[0]))%1000000000;
    rnd[1] = paniniCard.randomToBaseIdByRarity(rnd[0], 2); //baseid -> 1 rare
    _mintCardWithBaseId(_to, rnd[1]);

  }

  
  //bir secenek: yendigin rakibin puanina gore al?(search alg degisirse.)
  function _mintCardToWinner(address _to, int256 _score) internal {

    //NOTE-1: zamana, kisiye ve isleme bagli degisim var. Bu sayede;
    // farkli zamanlarda farkli kartlar uretilecektir(ayni kisi ve islem icin.).
    // farkli islemlerde farkli kartlar uretilecektir.(ayni kisi ve ayni zaman dilimi icin.).
    // farki kisiler icin farkli kartlar uretilecektir.(ayni zaman dilimi ve ayni islem icin.).
    //NOTE-2: 250 block yaklasik 1 saat yapmakta. Bu sayede brute force ile paket secmek oldukca zahmetli.
    uint256[] memory rnd = new uint256[](2); //last index: random
    rnd[0] = (uint256(keccak256(_to))%1000000)*(uint256(keccak256(mintedCardCount))%1000000); //kisiye bagli degisim*isleme bagli degisim
    rnd[1] = uint256(keccak256(block.blockhash( (block.number/250 )*250 )))%1000000;//zamana bagli degisim

    //1. card    
    rnd[0] = uint256(keccak256(rnd[0] * rnd[1]))%1000000000; 
    rnd[1] = uint256(_score);
    if(rnd[1] < 1600) {
      rnd[1] = 1;
    } else if(rnd[1] < 2400) {
      rnd[1] = rnd[0] % 100;
      if(rnd[1] < 70) {
        rnd[1] = 1;
      } else if(rnd[1] < 95) {
        rnd[1] = 2;        
      } else {
        rnd[1] = 3;        
      }
    } else {
      rnd[1] = rnd[0] % 100;
      if(rnd[1] < 60) {
        rnd[1] = 1;
      } else if(rnd[1] < 90) {
        rnd[1] = 2;        
      } else {
        rnd[1] = 3;        
      }
    }
    rnd[0] = paniniCard.randomToBaseIdByRarity(rnd[0], rnd[1]); //baseid -> common
    _mintCardWithBaseId(_to, rnd[0]);

  } 

  
  function isCardExist(uint256 _cardId) public view returns(bool) {
    uint256 card = cards[_cardId];
    if(card != 0) {
      return true;
    }    
  }

  function getCard(uint256 _cardId) public view returns(uint256) {
    uint256 card = cards[_cardId];
    return card;
  }

  
  function getCardInfo(uint256 _cardId) public view returns (uint256[]){
    uint256[] memory info = new uint256[](27);
        
    info[0] = (cards[_cardId] >> 100 ) & 1048575; //hp
    info[1] = (cards[_cardId] >> 80 ) & 1048575; //ap
    info[2] = (cards[_cardId] >> 60 ) & 1048575; //deff
    info[3] = (cards[_cardId] >> 40 ) & 1048575; //speed
    info[4] = (cards[_cardId] >> 20 ) & 1048575; //weight
    info[5] = (cards[_cardId] & 1048575);//lifespan
    //buffs. 1 to 10
    info[6] = (cards[_cardId] >> 192 ) & 255; //poison
    info[7] = (cards[_cardId] >> 184 ) & 255; //heal
    info[8] = (cards[_cardId] >> 176 ) & 255; //ap debuff
    info[9] = (cards[_cardId] >> 168 ) & 255; //ap buff
    info[10] = (cards[_cardId] >> 160 ) & 255; //deff debuff
    info[11] = (cards[_cardId] >> 152 ) & 255; //deff buff
    info[12] = (cards[_cardId] >> 144 ) & 255; //speed debuff
    info[13] = (cards[_cardId] >> 136 ) & 255; //speed
    info[14] = (cards[_cardId] >> 128 ) & 255; //lifesteal
    info[15] = (cards[_cardId] >> 120 ) & 255; //damage reflection
    //regions
    info[16] = (cards[_cardId] >> 228 ) & 15;
    info[17] = (cards[_cardId] >> 224 ) & 15;
    info[18] = (cards[_cardId] >> 220 ) & 15;
    info[19] = (cards[_cardId] >> 216 ) & 15;
    info[20] = (cards[_cardId] >> 212 ) & 15;
    info[21] = (cards[_cardId] >> 208 ) & 15;
    info[22] = (cards[_cardId] >> 204 ) & 15;
    info[23] = (cards[_cardId] >> 200 ) & 15;
    //rarity
    info[24] = (cards[_cardId] >> 232 ) & 15;

    //lvl
    info[25] = (cards[_cardId] >> 236 ) & 15;
    //baseid
    info[26] = (cards[_cardId] >> 240 ) & 32767;//max diff animal card. 2^8*2^7-1

    return info;

  }
}

contract A_PaniniGameCore {
    
  bool public isPaniniGameCore = true;

  //test
  uint256 lastGameResult;

  struct PlayerGameState {
    int256 damage;
    int256 defenderHp;//daha az islem icin.
    uint256 defenderCardIndex;
    uint256[] lifes;
    bool cardDeath;
  }

  //set panini
  PaniniBase panini;
  function setA_PaniniContract(address _address) public {  
    require(address(panini) == address(0) && _address != address(0) );        
    panini = PaniniBase(_address);
  }

  function kill() public  {
    selfdestruct(msg.sender);
  }

  function getLastGameResult() public view returns(uint256) {
    return lastGameResult;
  }

  function getHerd(uint256 _card1, uint256 _card2, uint256 _card3, uint256 _card4) public view returns(uint256) {
    return (_card1 
    | (_card2 << 32)
    | (_card3 << 64)
    | (_card4 << 96));
  }  

  function _sIdxs(uint256[] _arr)  internal pure returns(uint256[]) {
    //_arr : a,b,c,d
    uint256[] memory indexs = new uint256[](5);//4->temp. + index when using.
    if((_arr[0] & 1048575) < (_arr[1] & 1048575)) {
        indexs[0] = 0;
        indexs[1] = 1;
    } else {
        indexs[0] = 1;
        indexs[1] = 0;
    }//[x,y] x<y (z = min(a,b), t = max(a,b) )

    if((_arr[2] & 1048575) < (_arr[3] & 1048575)) {
        indexs[2] = 2;
        indexs[3] = 3;
    } else {
        indexs[2] = 3;
        indexs[3] = 2;
    }//[z,t] z<t (z = min(c,d), t = max(c,d) )

    //son case.
    //not://y<z =< x,y,z,t //bisey yapmaya gerek yok.

    //t<x => z<t < x<y
    if((_arr[indexs[3]] & 1048575) < (_arr[indexs[0]] & 1048575)) {
        indexs[4] = indexs[0];//temp
        indexs[0] = indexs[2];
        indexs[2] = indexs[4];
        indexs[4] = indexs[1];//temp
        indexs[1] = indexs[3];
        indexs[3] = indexs[4];
    } 
    //z<x => z,x,y,t | z,x,t,y (her zaman z<y)
    else if((_arr[indexs[2]] & 1048575) < (_arr[indexs[0]] & 1048575)) {
      //t<y => z,x,t,y
      if((_arr[indexs[3]] & 1048575) < (_arr[indexs[1]] & 1048575)) {
        indexs[4] = indexs[0];//temp
        indexs[0] = indexs[2];//z
        indexs[2] = indexs[4];//t
        indexs[3] = indexs[1];//y
        indexs[1] = indexs[4];//x
      } else {//z,x,y,t
        indexs[4] = indexs[0];//temp
        indexs[0] = indexs[2];//z
        indexs[2] = indexs[1];//y
        indexs[1] = indexs[4];//x
        //t already there.
      }
    } 
    //(herzaman x < (z,t))
    // t<y => x<z<t<y
    else if((_arr[indexs[3]] & 1048575) < (_arr[indexs[1]] & 1048575)) {
      indexs[4] = indexs[1];//temp
      indexs[1] = indexs[2];
      indexs[2] = indexs[3];
      indexs[3] = indexs[4];
    } 
    //y<t => x<z<y<t | 
    else if((_arr[indexs[2]] & 1048575) < (_arr[indexs[1]] & 1048575)) {
      indexs[4] = indexs[1];//temp
      indexs[1] = indexs[2];
      indexs[2] = indexs[4];
    }
    //else x<y<z<t
    indexs[4] = 0; //index of start.
    return indexs; 
  }
     
  //returns 800 - 1200  : 1k = 1.
  //weightRate : w1/w2 ->p1, w2/w1 ->p2
  function _cWF(uint256 _weightRate ) public pure returns(uint256) {
    //kusurat icin *1000    
    if(_weightRate <= 50) {
      return 2*_weightRate + 900;
    } else if(_weightRate <= 150) {
      return _weightRate + 950;
    }
    return 1100;
  }
  
  function _cWFs( uint256 _weight1, uint256 _weight2 ) public pure returns(uint256,uint256){
     return ( 
      _cWF((_weight1 *100 ) / (_weight2 + 1)), 
      _cWF((_weight2 *100 ) / (_weight1 + 1))
    );
  }

  // 0-9000(for %0-90).
  function _cDefF(int256 _deff ) public pure returns(uint256) {
    //kusurat icin *1000    
    if(_deff <= 0) {
      return 1;
    } else if(_deff <= 250) {
      return uint256(10*_deff);
    } else if(_deff <= 500) {
      return uint256(8*_deff + 500);
    } else if(_deff <= 1000) {
      return uint256(5*_deff + 2000);
    } else if(_deff < 2000 ) {
      return uint256(2*_deff + 5000);
    }
    return 9000;
  }

  //0-600
  //600-
  function _cSpF(uint256 _sp ) public pure returns(uint256) {
    //kusurat icin *1000    
    if(_sp <= 60) {
      return 10*_sp;//10-600
    } else if(_sp <= 120) {
      return 6*_sp + 240;//600-960
    } else if(_sp <= 180) {
      return 2*_sp + 720;//960-1080
    } 
    return _sp + 900;
  }

  //0-600
  //600-
  function _cApF(uint256 _ap ) public pure returns(uint256) {
    //kusurat icin *1000    
    if(_ap <= 100) {
      return 10*_ap;//10-1000
    } else if(_ap <= 200) {
      return 7*_ap + 300;//1000-1700
    } else if(_ap <= 400) {
      return 4*_ap + 900;//1700-2500
    } 
    return 2*_ap + 1700;//2500++
  }

  //ap: ~400
  //sp: ~250
  //wf: ~1000
  //(ap*sp*wf) : ~10^8
  //df: ~1000(max) : normalde 500 civaridir.x10
  //(dk*5xAp*5xSp) :(60*5*5 = 1500) : 1.5*10^3
  function _cDamF(uint256 _ap, uint256 _sp, uint256 _wf, uint256 _df, uint256 _lives ) public pure returns(uint256) {
    return ( _cApF(_ap+50) * _cSpF(_sp+30) *(18000 - _wf)) / (_df*_lives*60000000000);//(10*600*10);
  }

  function _cApSpBfs(uint256 _cards, uint256 _buffs, uint256 _enemyBuffs) public pure returns(uint256,uint256){
    return (uint256(
      int256(((_cards >> 80 ) & 1048575)) 
      + (
        int256(((_cards >> 80 ) & 1048575)) 
      * (int256(((_buffs >> 168 ) & 255 )) - int256(((_enemyBuffs >> 176 ) & 255 ))) 
      )/1000),
      uint256(
      int256(((_cards >> 40 ) & 1048575))
      + (
        int256(((_cards >> 40 ) & 1048575)) 
      * (int256(((_buffs >> 136 ) & 255)) - int256(((_enemyBuffs >> 144 ) & 255))) 
      )/1000)
    );
  }
  
  function _cDeffFBfs(uint256 _cards, uint256 _buffs, uint256 _enemyBuffs) public pure returns(uint256){
    //p1 deffFactor
    return _cDefF(int256(((_cards >> 60 ) & 1048575))
      + (
        int256(((_cards >> 60 ) & 1048575 )) 
      * (int256(((_buffs >> 152 ) & 255 )) - int256(((_enemyBuffs >> 160 ) & 255 ))) 
      )/1000);
  }

  function _cRBfs(uint256[] _c, uint256[] regionBuffs, uint256 _card ) public pure returns(uint256[]){
    _c[8] = 0;
    _c[9] = _card >> 200;
    for(uint8 i = 0; i < 8; i++) {
      _c[10] = _c[9] & 15;
      if(_c[10] > 1) {//2,3,4 icin
        _c[8] += regionBuffs[i] >> ((_c[10] -2 )*80);
      }
      _c[9] = _c[9] >> 4;
    }
    _c[8] = (_c[8] & 1208925819614629174706175 ) << 120;
  }
    //a0,s1,df2,wf3,wf4,df5,df6
    //calcData: [ap, sp, deffFactor, weightFactor1, weightFactor2]; ao, sp, deffFactor <-(for p1, p2)
    //damageFactor1, damageFactor2 
  //calcs: damages, lifesteal,damagareflect, heal, poison. -> to just a single damage.
  function _cDmgs(uint256[] _c, uint256[] regionBuffs,
    int256 _p1DefenderHp, uint256 _p1Defender, uint256 _p1Cards,
    int256 _p2DefenderHp, uint256 _p2Defender, uint256 _p2Cards ) public pure returns(int256,int256){
    //calc buffs with region buff.
    //_c[7] -> p1 buffs
    //_c[8] -> p2 buffs
    _cRBfs(_c, regionBuffs, _p1Cards );
    _c[7] = _p1Cards + _c[8];
    _cRBfs(_c, regionBuffs, _p2Cards );
    _c[8] += _p2Cards;
    //p1,p2 weight factors   
    (_c[3], _c[4]) = _cWFs( (_p1Cards >> 20 ) & 1048575, (_p2Cards >> 20 ) & 1048575);

    //## p1:damage factor(calcData5)
    //ap, sp -> p1
    (_c[0], _c[1]) = _cApSpBfs( _p1Cards, _c[7], _c[8]);
    //deffFactor -> p2
    _c[2] = _cDeffFBfs(_p2Cards, _c[8], _c[7]);
    _c[5] = _cDamF(_c[0], _c[1], _c[3], _c[2], _c[11] );

    //## p2:damage factor(calcData6)
    //ap, sp -> p2
    (_c[0], _c[1]) = _cApSpBfs( _p2Cards, _c[8], _c[7]);
    //deffFactor -> p1
    _c[2] = _cDeffFBfs(_p1Cards, _c[7], _c[8]);
    _c[6] = _cDamF(_c[0], _c[1], _c[4], _c[2], _c[12] );
    //passive1,2,9,10 /p1,p2

    return (
      //p1 heal+poison: p1damage += p2Hp*(p1.poison - p2.heal)(rakibin hp'si uzerinden kendi poisonunu ekle, rakibin heal'ini cikar. )
      //p1 lifeSteal: p1damage -= (p2.damage*p2Cards[0].passive9)/1000;(rakibin lifesteal'ini kendi damagesinden cikart.)
      //p1 damage reflection: p1damage += (p2.damage*p1Cards[0].passive10)/1000; (rakibin damagesini kendi passif dam.reflectionu ile kendi damagesine ekle.)
      int256(_c[5]) + 
      (  _p2DefenderHp *int256((((_p1Cards >> 192 ) & 255 ))) - int256(( (_p2Cards >> 184 ) & 255 ))
        //burasi toplanabilir sonra.
       - int256((_c[6] * ((_p2Defender >> 128 ) & 255 )))
       + int256((_c[6] * ((_p1Defender >> 120 ) & 255 )))

      )/1000,
    
      //p2 heal+poison: p2damage += p1Hp*(p2.poison - p1.heal)(rakibin hp'si uzerinden kendi poisonunu ekle, rakibin heal'ini cikar. )
      //p2 lifeSteal: p2damage -= (p1.damage*p1Cards[0].passive9)/1000;(rakibin lifesteal'ini kendi damagesinden cikart.)
      //p2 damage reflection: p2damage += (p1.damage*p2Cards[0].passive10)/1000; (rakibin damagesini kendi passif dam.reflectionu ile kendi damagesine ekle.)
      int256(_c[6]) + 
      (  _p1DefenderHp *int256((((_p2Cards >> 192 ) & 255 ))) - int256(( (_p1Cards >> 184 ) & 255 ))
        //burasi toplanabilir sonra.
       - int256((_c[5] * ((_p1Defender >> 128 ) & 255 )))
       + int256((_c[5] * ((_p2Defender >> 120 ) & 255 )))
      )/1000
    );
  }

  function getCards(uint256 _herd) public view returns (uint256[]){
    uint256[] memory _cards = new uint256[](5);
    _cards[0] = panini.getCard(_herd & 4294967295);
    _cards[1] = panini.getCard((_herd>>32) & 4294967295);
    _cards[2] = panini.getCard((_herd>>64) & 4294967295);
    _cards[3] = panini.getCard((_herd>>96) & 4294967295);
    _cards[4] = _cards[0] + _cards[1] + _cards[2] + _cards[3];
    return _cards;

  }

  // 0 => not end.
  // 1 => player1 winner
  // 2 => player2 winner
  // 3 => draw

  //107839786687433864387751105914587979168133710367608538813840266100741
  //377439253421711279702903080799854032988620333341161505157109205958671
  function _calculateGameState(uint256 herd1, uint256 herd2, uint256 _turn) public returns(uint256) {
    uint256[] memory regionBuffs = new uint256[](8);
    regionBuffs[0] = 0x0000000028500000000000000000281e0000000000000000001e00000000;
    regionBuffs[1] = 0x1e1e0000002800000000001e0000002800000000001e0000000000000000;
    regionBuffs[2] = 0x0000001e005a000000000000001e0028000000000000001e000000000000;
    regionBuffs[3] = 0x00000028000000500000000000280000001e0000000000000000001e0000;
    regionBuffs[4] = 0x002800500000000000000028001e0000000000000000001e000000000000;
    regionBuffs[5] = 0x5a0000000000000000003200000000000000000014000000000000000000;
    regionBuffs[6] = 0x000032003200002800000000000032000028000000000000320000000000;
    regionBuffs[7] = 0x00500000280000000000001e0000280000000000001e0000000000000000;

    //a0,s1,df2,wf3,wf4,df5,df6
    //calcData: [ap, sp, deffFactor, weightFactor1, weightFactor2]; ao, sp, deffFactor <-(for p1, p2)
    //damageFactor1, damageFactor2 
    //regionBuffs1, regionBuffs2 -> to to buffs. , + shiftedRegion , index
    //11,12 -> p1,p2 yasayan hayvan sayisi
    uint256[] memory calcData = new uint256[](13);
    //player1 data
    //region -> p1Cards'da
    //buffs -> p1Cards'da 
    //5. index sum of 1-4
    uint256[] memory p1Cards = getCards(herd1);
    
    //player2 data
    //region -> p2Cards'da
    //buffs -> p2Cards'da
    //5. index sum of 1-4
    uint256[] memory p2Cards = getCards(herd2);  
    

    PlayerGameState memory p1 = PlayerGameState(
      0, //int256 damage;
      int256((p1Cards[0] >> 100 ) & 1048575), //defenderHp
      0, //uint256 defenderCardIndex;
      _sIdxs(p1Cards),
      false//cardDeath
    );
    
    PlayerGameState memory p2 = PlayerGameState(
      0, //int256 damage;
      int256((p2Cards[0] >> 100 ) & 1048575), //defenderHp
      0, //uint256 defenderCardIndex;      
      _sIdxs(p2Cards),
      false//cardDeath
    );
    calcData[11] = 4;
    calcData[12] = 4;
    (p1.damage, p2.damage) = _cDmgs(calcData, regionBuffs,
      p1.defenderHp, p1Cards[0], p1Cards[4],
      p2.defenderHp, p2Cards[0], p2Cards[4] );
    //iki saldiri'da ayni anda yapilacak.
    //60 => 60 sec.(1min) 
    //   for(uint256 i = game.startTime; i < _time; i = i + 60) { //time lapse :2 sec, it will be change.
    for(uint256 i = 0; i < _turn; i++) { //time lapse :2 sec, it will be change.

      //####################################
      //ATTACK P1-P2 AND DAMAGE DONE
      //####################################
      if(p1.defenderHp <= p2.damage) {
        //Damage can'dan cok ise oldur.
        p1.defenderHp = 0; //defender'in olmesi durumunda defendirin oldurulmesi asagida yapilmakta.
        p1.cardDeath = true;
        calcData[11] -= 1;
      } else {
        //damage can'dan az. uygula.
        p1.defenderHp -= p2.damage;
        //eger heal + lifesteal yuzunden damage negatif ise. max hp'yi gecme
        if(p2.damage < 0 && p1.defenderHp > int256(((p1Cards[p1.defenderCardIndex] >> 100 ) & 1048575)) ) {
          p1.defenderHp = int256(((p1Cards[p1.defenderCardIndex]>> 100 ) & 1048575));
        }
      }
      //p2
      if(p2.defenderHp <= p1.damage) {
        p2.defenderHp = 0; 
        p2.cardDeath = true;
        calcData[12] -= 1;
      } else {
        p2.defenderHp -= p1.damage;
        if(p1.damage < 0 && p2.defenderHp > int256(((p2Cards[p2.defenderCardIndex] >> 100 ) & 1048575)) ) {
          p2.defenderHp = int256(((p2Cards[p2.defenderCardIndex] >> 100 ) & 1048575));
        }
      }

      //####################################
      //P1-P2 LIFE SPAN
      //####################################
      //buraya gelirken: defender olmus olabilir veya yasiyordur.
      //defender olmus ise?
      // not:  bu index hesaplama defender'dan sonra yapilmali?
      //p1 aktive life span deaths.
      if((p1Cards[p1.lifes[p1.lifes[4]]]  & 1048575)<= i) {
        //olen defender mi?
        if(p1.lifes[p1.lifes[4]] == p1.defenderCardIndex) {
          p1.defenderHp = 0; //defender'in olmesi durumunda defendirin oldurulmesi asagida yapilmakta.
        } else {
          //kart'i oldur.
          p1Cards[p1.lifes[p1.lifes[4]]] = p1Cards[4] - p1Cards[p1.lifes[p1.lifes[4]]];  
          p1Cards[p1.lifes[p1.lifes[4]]] = 0;
        }
        p1.lifes[4] += 1;
        p1.cardDeath = true;
        calcData[11] -= 1;
      }
      //p2
      if((p2Cards[p2.lifes[p2.lifes[4]]]  & 1048575)<= i) {
        if(p2.lifes[p2.lifes[4]] == p2.defenderCardIndex) {
          p2.defenderHp = 0;
        } else {
          p2Cards[p2.lifes[p2.lifes[4]]] = p2Cards[4] - p2Cards[p2.lifes[p2.lifes[4]]];  
          p2Cards[p2.lifes[p2.lifes[4]]] = 0;
        }
        p2.lifes[4] += 1;
        p2.cardDeath = true;
        calcData[12] -= 1;
      }
     
      //####################################
      //P1 DEFENDER DIED. SET NEXT DEFENDER
      //####################################
      if(p1.defenderHp == 0) {
        //DEFENDER'IN OLDURULMESI
        p1Cards[4] = p1Cards[4] - p1Cards[p1.defenderCardIndex];          
        p1Cards[p1.defenderCardIndex] = 0;
        //siradaki defender'a gec.
        p1.defenderCardIndex++;
        //life span ile olen defender'lari atla.
        //defender index bu if-else'de max 4 olmakta!
        //ONEMLI:defender index 4 olunca yasayan kart kalmadi demektir.
        if(p1.defenderCardIndex < 4 && ((p1Cards[p1.defenderCardIndex] >> 100 ) & 1048575) == 0) {
          p1.defenderCardIndex++;
          if(p1.defenderCardIndex < 4 && ((p1Cards[p1.defenderCardIndex] >> 100 ) & 1048575) == 0) {
            p1.defenderCardIndex++;
            if(p1.defenderCardIndex < 4 && ((p1Cards[p1.defenderCardIndex] >> 100 ) & 1048575) == 0) {
              p1.defenderCardIndex++;
            }     
          }   
        }

        //DEFENDER INDEX 4 DEGIL ISE
        if(p1.defenderCardIndex < 4) {
          p1.defenderHp = int256(( p1Cards[p1.defenderCardIndex] >> 100 ) & 1048575);          
        }
      }
      //p2
      if(p2.defenderHp == 0) {
        p2Cards[4] = p2Cards[4] - p2Cards[p2.defenderCardIndex];          
        p2Cards[p2.defenderCardIndex] = 0;
        p2.defenderCardIndex++;
        if(p2.defenderCardIndex < 4 && ((p2Cards[p2.defenderCardIndex] >> 100 ) & 1048575) == 0) {
          p2.defenderCardIndex++;
          if(p2.defenderCardIndex < 4 && ((p2Cards[p2.defenderCardIndex] >> 100 ) & 1048575) == 0) {
            p2.defenderCardIndex++;
            if(p2.defenderCardIndex < 4 && ((p2Cards[p2.defenderCardIndex] >> 100 ) & 1048575) == 0) {
              p2.defenderCardIndex++;
            }     
          }   
        }

        //DEFENDER INDEX 4 DEGIL ISE
        if(p2.defenderCardIndex < 4) {
          p2.defenderHp = int256(( p2Cards[p2.defenderCardIndex] >> 100 ) & 1048575);          
        }
      }


      //oyun devam ediyor ise
      if(p1.defenderCardIndex < 4 && p2.defenderCardIndex < 4) {

        //p1-p2 aktiveLifes index'i yenden set et.
        //buradan once lifes index 4 olabilir(son defender'i oldurdu.). ancak yukaridaki if'e giriyorsa son defender degildir.
        //bu durumda asagidan cikarken her zaman p2.aktiveLifes[4] < 4.
        if( p1.cardDeath && p1.lifes[p1.lifes[4]] < p1.defenderCardIndex) {
          p1.lifes[4] += 1;
          if(p1.lifes[p1.lifes[4]] < p1.defenderCardIndex) {
            p1.lifes[4] += 1;
            if(p1.lifes[p1.lifes[4]] < p1.defenderCardIndex) {
              p1.lifes[4] += 1;
            }
          }
        }
        if( p2.cardDeath && p2.lifes[p2.lifes[4]] < p2.defenderCardIndex) {
          p2.lifes[4] += 1;
          if(p2.lifes[p2.lifes[4]] < p2.defenderCardIndex) {
            p2.lifes[4] += 1;
            if(p2.lifes[p2.lifes[4]] < p2.defenderCardIndex) {
              p2.lifes[4] += 1;
            }
          }
        }

        //bir kart olduyse.
        //DAMAGE HESAPLA
        if( p1.cardDeath || p2.cardDeath ) {
          (p1.damage, p2.damage) = _cDmgs(calcData, regionBuffs,
            p1.defenderHp, p1Cards[p1.defenderCardIndex], p1Cards[4],
            p2.defenderHp, p2Cards[p2.defenderCardIndex], p2Cards[4] );

          p1.cardDeath = false;
          p2.cardDeath = false;
        }
      
      }
      else {
        //kazanma kaybetme berabere durumlari
        if(p1.defenderCardIndex == 4 && p2.defenderCardIndex == 4) {
          //berabere
          lastGameResult = 3;
          return 3;
        } else if(p2.defenderCardIndex == 4) {
          //p1 winner
          lastGameResult = 1;
          return 1;
        }
        //p2 winner
        lastGameResult = 2;
        return 2;
      } 

    }
    lastGameResult = 0;
    return 0;
  }
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
contract A_Panini is UsingCard{

  int256 NEW_PLAYER_SCORE = 1200;
  int256 MIN_SCORE = 800;
  int256 MAX_SCORE = 2800;
  int256 SCORE_GAP = 50;

  struct PlayerData {
    uint256 id; 
    string name;
    int256 score;
  }

  struct GameData {
    uint256 id;  //0 olabilir.
    address player1;
    address player2;
    uint256 startTime;
    uint256 p1Herd;
    uint256 p2Herd;    
    uint256 state; // 0 baslangic. 1. 1. oyuncu ready. 2. 2. oyuncu ready. 3. iki oyuncu'da ready.
  }
    
  mapping (address => PlayerData) players;
  uint256 numberOfPanini;

  //hash map of arrays in score window
  //800-> 800-850 , 850-900, 900-950
  //1123 ->1100
  mapping (int256 => GameData[]) pendingGames;   
  uint256 numberOfGames;

  mapping (uint256 => GameData) availableGames;
  //mapping (uint256 => GameData) finishedGames;
  //Bir oyuncuya ait oyun
  //not: bir seferde tek bir oyun baslatabilsin.
  mapping (address => uint256) myGame;    
  mapping (address => int256[]) myPendingGame;//address-> 0 -> score index, 1 -> i of pendingGames.Data[]    


  function A_Panini() public {

  }

  function kill() public  {
    selfdestruct(msg.sender);
  }

  function setA_PaniniGameCore(address _address) __onlyIfAX_PaniniController public {
      require(address(gameCore) == address(0) && _address != address(0) );        
      gameCore = A_PaniniGameCore(_address);
      //require(gameCore.isPaniniGameCore());
      gameCore.setA_PaniniContract(address(this));
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
    numberOfPanini = numberOfPanini + 1;
    players[msg.sender].id = numberOfPanini;
//    players[msg.sender].owner = msg.sender;
    players[msg.sender].name = _name;
    players[msg.sender].score = NEW_PLAYER_SCORE;
    //10x card 
    _mintNewPlayerCards(msg.sender);
  }    

  function getPlayerName() __isPlayer public view returns(string) {
    return players[msg.sender].name;
  }

  //bu method value degeri girilerek web3 tarafinda cagrilacak.
  function buyPackage(uint256 _numberOfPackage) __isPlayer __whenNotPaused public payable {
    mutex.enter();

    uint256 price = paniniCardPackage.computePriceOfPackage(_numberOfPackage);
    require (price >= msg.value);
    uint256[] memory baseIds = new uint256[](5);
    for(uint256 i = 0; i < _numberOfPackage; i++) {
      (baseIds[0], baseIds[1], baseIds[2], baseIds[3], baseIds[4]) 
        = paniniCardPackage.createPackage(msg.sender);
      _mintCardWithBaseId(msg.sender, baseIds[0]);
      _mintCardWithBaseId(msg.sender, baseIds[1]);
      _mintCardWithBaseId(msg.sender, baseIds[2]);
      _mintCardWithBaseId(msg.sender, baseIds[3]);
      _mintCardWithBaseId(msg.sender, baseIds[4]);
    }

    if(price > msg.value) {
      require(msg.sender.call.value(msg.value - price)());
    }

    //TODO: bu distributeBalance artik paniniState'de. El atilacak.
    require(address(paniniController).call.value(price)());
    paniniController.distributeBalance(price);        
    mutex.left();
  }

  function upgradeCard(uint256 _cardId, uint256 _burnedCardId) __isPlayer __whenNotPaused public {
    _upgradeCard(_cardId, _burnedCardId);
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

  //#############################
  //GAME CODES
  //#############################
  function getMyGame() public view returns(uint256) {
    return myGame[msg.sender];
  }

  function generateCryptoHerdByCards(uint256 _card1, uint256 _card2, uint256 _card3, uint256 _card4, string _secret) __isPlayer public view returns(uint256) {
    //note: hile ile herd'i olustursa bile entersacretAvailableGame'i gerceklestiremeyecektir.
    require(_card1 != _card2 && _card1 != _card3 && _card1 != _card4);
    require(_card2 != _card3 && _card2 != _card4 && _card3 != _card4);

    return ( _card1 
      | (_card2 << 50)
      | (_card3 << 100)
      | (_card4 << 150)) + uint256(( keccak256(_secret) & 1606938044258990275541962092341162602522202993782792835301375));        
  }

  //oyun bulursa oyun baslatir
  //bulamaz ise siraya girer
  function enterQueue(uint256 _cryptoHerd ) __isPlayer __whenNotPaused public {
    //myPendingGame'de kendisi yok ise. 2. kez oyun arama baslatamaz. 
    // bu kontrol ayrica rakip olarak kendisiyle eslesmesinin de onune gecmesini sagliyor.
    require(myPendingGame[msg.sender][0] == 0);

    int256 index = (players[msg.sender].score / SCORE_GAP) * SCORE_GAP; // kusurat atildi.
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
      GameData memory game = pendingGames[index][lastIndex];

      myPendingGame[game.player1][0] = 0;
      delete pendingGames[index][lastIndex];
      pendingGames[index].length = pendingGames[index].length -1;

      //hizli erisim icin.
      numberOfGames +=1; //id.
      game.id = numberOfGames;
      game.player2 = msg.sender;
      game.p2Herd = _cryptoHerd;
      game.startTime = now;
      availableGames[game.id] = game;

      myGame[game.player1] = game.id;
      myGame[game.player2] = game.id;

    } else {
      //note: struct olustururken null veremedigimiz icin hersey player1
      //starttime = created time for pending players.
      /*uint256 id;  //0 olabilir.
      address player1;
      address player2;
      uint256 startTime;
      Herd p1Herd;
      Herd p2Herd;  
      state  */
      GameData memory newGame = GameData(0, msg.sender, address(0), now, _cryptoHerd, 0, 0);

      myPendingGame[msg.sender][0] = index;
      myPendingGame[msg.sender][1] = int256(pendingGames[index].length); 
      pendingGames[index].push(newGame);
    } 

  }

  function stopQueue() __isPlayer __whenNotPaused public {    
    if(myPendingGame[msg.sender][0] != 0) {
      delete pendingGames[myPendingGame[msg.sender][0]][uint256(myPendingGame[msg.sender][1])];
      myPendingGame[msg.sender][0] = 0;      

    }
  }


  //bu islem gerceklestikten 1? saat sonra oyun baslatilabiliyor.
  function enterAvailableGameSacret(uint256 _gameId, string _secret ) __isPlayer __whenNotPaused public view{
    GameData memory game = availableGames[_gameId];
    uint256[] memory herd = new uint256[](4);
    require(game.id != 0);

    if(game.player1 == msg.sender && game.state != 1 && game.state != 3 ) {
      
      game.p1Herd = game.p1Herd - uint256(( keccak256(_secret) & 1606938044258990275541962092341162602522202993782792835301375));
      game.state += 1;
      game.startTime = now;
      herd[0] = game.p1Herd & 1125899906842623;
      herd[1] = (game.p1Herd>>50) & 1125899906842623;
      herd[2] = (game.p1Herd>>100) & 1125899906842623;
      herd[3] = (game.p1Herd>>150) & 1125899906842623;

    } else if(game.player2 == msg.sender && game.state != 2 && game.state != 3 ) {
    
      game.p2Herd = game.p2Herd - uint256(( keccak256(_secret) & 1606938044258990275541962092341162602522202993782792835301375));
      game.state += 2;      
      game.startTime = now;    
      herd[0] = game.p2Herd & 1125899906842623;
      herd[1] = (game.p2Herd>>50) & 1125899906842623;
      herd[2] = (game.p2Herd>>100) & 1125899906842623;
      herd[3] = (game.p2Herd>>150) & 1125899906842623;

    }

    require(herd[0] != herd[1] && herd[0] != herd[2] && herd[0] != herd[3]);
    require(herd[1] != herd[2] && herd[1] != herd[3] && herd[2] != herd[3]);
    require(ownerOf(herd[0]) == address(msg.sender));
    require(ownerOf(herd[1]) == address(msg.sender));
    require(ownerOf(herd[2]) == address(msg.sender));
    require(ownerOf(herd[3]) == address(msg.sender));

  }

  //p1: winner.  
  function _reCalcScores(address _p1, address _p2, bool _draw ) internal {

    int256[] memory c = new int256[](4);
    c[0] = players[_p1].score;
    c[1] = players[_p2].score;
    //note: c2 -> p1 score, c3 -> p2 score
    if(_draw && (c[0] != c[1]) ) {
      if(c[0] < c[1]) {
        c[2] = c[0] + (c[1] - c[0])/100;
        c[3] = c[1] - (c[1] - c[0])/100;
        if(c[3] < 800) {
          c[3] = 800;
        }
      } else {
        c[2] = c[0] - (c[0] - c[1])/100;
        c[3] = c[1] + (c[0] - c[1])/100;
        if(c[2] < 800) {
          c[2] = 800;
        }        
      }
    } else {
      c[2] = (MAX_SCORE - c[0]);
      c[3] = (MAX_SCORE - c[1]);
      if(c[2] <= 20) {
        c[2] = 20;  
      }
      if(c[3] <= 20) {
        c[3] = 20;  
      }
      c[2] = c[0] + c[2] * ((c[0] + c[1]) / (100*c[0]));
      c[3] = c[0] - c[3] * ((c[0] + c[1]) / (100*c[1]));
      if(c[3] < 800) {
        c[3] = 800;
      }
    }

    if(c[0] != c[2]) {
      players[_p1].score = c[2];
    }
    if(c[1] != c[3]) {
      players[_p2].score = c[3];
    }
  }
  
  //function calculateGameState(uint256 _gameId, uint256 _time)
  function checkEndFinishGame(uint256 _gameId) public returns(string) {
    //TODO: Check gameId
    GameData memory game = availableGames[_gameId];
    require(game.id != 0);
    require((now - game.startTime) > 600);
    if(game.state == 0 ) {
        return "oyun henuz baslatilmadi.";
    } else {
      uint256 gameState = game.state;
      if(gameState == 3 ) {
        gameState = gameCore._calculateGameState(game.p1Herd, game.p2Herd, (now - game.startTime) / 60 );
      }

      if(gameState == 0) {      
        return "oyun devam ediyor.";

      } else {

        delete availableGames[_gameId];
        delete myGame[game.player1];
        delete myGame[game.player2];

        if(gameState == 1) {
          _mintCardToWinner(game.player1, players[game.player1].score);
          _reCalcScores(game.player1, game.player2, false);
          return "1. oyuncu kazandi";    
        } else if(gameState == 2) {
          _mintCardToWinner(game.player2, players[game.player2].score);
          _reCalcScores(game.player2, game.player1, false);
          return "2. oyuncu kazandi";    
        } else if(gameState == 3) {
          _reCalcScores(game.player1, game.player2, true);
          return "Berabere.";    
        }
      }
    }
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


contract AX_PaniniController is PaniniDevAccounts, UsingShareholder {

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
    address _paniniGameCoreAddress,
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

    candidatePaniniState.attachAX_PaniniController();
    candidatePaniniCard.attachAX_PaniniController();
    candidatePaniniCardPackage.attachAX_PaniniController();
    candidatePaniniMarket.attachAX_PaniniController();
    candidatePaniniBase.attachAX_PaniniController();

    candidatePaniniCard.setA_PaniniState(_paniniStateAddress);
    candidatePaniniCardPackage.setA_PaniniState(_paniniStateAddress);
    candidatePaniniMarket.setA_PaniniState(_paniniStateAddress);
    candidatePaniniBase.setA_PaniniState(_paniniStateAddress);

    candidatePaniniCardPackage.setA_PaniniCard(_paniniCardAddress);
    candidatePaniniBase.setA_PaniniCard(_paniniCardAddress);
    candidatePaniniBase.setA_PaniniCardPackage(_paniniCardPackageAddress);
    candidatePaniniBase.setA_PaniniMarket(_paniniMarketAddress);
    candidatePaniniBase.setA_PaniniGameCore(_paniniGameCoreAddress);

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
  
  
  function createCardBase(uint256 _metedata ) __OnlyForThisRoles1(true, Role.RoleType.COO) public {
    paniniCard.createCardBase( _metedata );
  }

  function () public payable {

  }

}
