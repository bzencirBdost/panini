pragma solidity 0.4.21;

contract A2_Player{
  mapping (uint256=>uint256) cards;


  function A2_Player() public {

    cards[1] = 0x4610000000000000640000000000000032000050000c800032000be0001a;
    cards[2] = 0x46100000000032000000000000000000050000140001400018000060000e;
    cards[3] = 0x051000000000000000000000780000000960001e000320004b0025800013;
    cards[4] = 0x191000000000000000005000000000003e8000320012c00023004b000011;
    cards[5] = 0x05100000000000000000000000280000258000500009600028000dc0000f;
    cards[6] = 0x051000000000000000000000500000000640003c00032000960000700012;
    cards[7] = 0x4601000000003c000000000000000000014000050000a000400000100012;
    cards[8] = 0x4601000000000000500000000000000001e0001e0001e000110000100016;
    cards[9] = 0x46001000000000000000003c000000000c80000a00064000520012c0000f;
    cards[10] = 0x460010000028000000000000000000000320002800032000030000100018;
    cards[11] = 0x460010000000000000000000003c00000fa00046000960004b000200000c;
    cards[12] = 0x190001000000000000000000780000000fa0005a0005000070000300000b;
    cards[13] = 0x1900010000000000003c00000000000015e0006e000780003c0004d00018;
    cards[14] = 0x19000100000000003c000000000000006400003c000640002d009c40002d;
    cards[15] = 0x050001000000000064000000000000003e800064001900002a0044c0002f;
    cards[16] = 0x1900010000280000000000000000000000a000280000a00005000020000b;
    cards[17] = 0x0500001000003c00000000000000000012c0000a0012c00020000b400020;
    cards[18] = 0x050000100000000000006400000000006a400078001f40002b00fa000043;
    cards[19] = 0x1900001000320000000000000000000003c0003200032000070000500012;
    cards[20] = 0x050000010000000050000000000000000780003200050000180000700007;
    cards[21] = 0x4600000100000000000000000000c8000c80001400064000370004100007;
    cards[22] = 0x050000010000320000000000000000000140000a0000a000020000800012;
    cards[23] = 0x4600000010000000000000000000960025800014000c8000130070800013;
    cards[24] = 0x050000000100000000000000002800005780005a000640002c01d4c00038;
    cards[25] = 0x190000000100000000640000000000003200005000064000180067200026;
  }


  function getHp(uint256 _cardId) public view returns(uint256) {
    uint256 card = getCard(_cardId);
    return (card >> 100 ) & 1048575;
  } 
  
  function getLifeSpan(uint256 _cardId) public view returns(uint256) {
    uint256 card = getCard(_cardId);
    return (card & 1048575);
  } 


  function getCard(uint256 _cardId) public view returns(uint256) {
    uint256 card = cards[_cardId];
    if(card != 0) { 
      return card;
    }    
  }
  

  function getCardInfo(uint256 self) public view returns (uint256[]){
    uint256[] memory info = new uint256[](25);
    info[0] = (self >> 100 ) & 1048575; //hp
    info[1] = (self >> 80 ) & 1048575; //ap
    info[2] = (self >> 60 ) & 1048575; //deff
    info[3] = (self >> 40 ) & 1048575; //speed
    info[4] = (self >> 20 ) & 1048575; //weight
    info[5] = (self & 1048575);//lifespan
    //buffs. 1 to 10
    info[6] = (self >> 192 ) & 255; //buff10
    info[7] = (self >> 184 ) & 255; //buff10
    info[8] = (self >> 176 ) & 255; //buff10
    info[9] = (self >> 168 ) & 255; //buff10
    info[10] = (self >> 160 ) & 255; //buff10
    info[11] = (self >> 152 ) & 255; //buff10
    info[12] = (self >> 144 ) & 255; //buff10
    info[13] = (self >> 136 ) & 255; //buff10
    info[14] = (self >> 128 ) & 255; //buff10
    info[15] = (self >> 120 ) & 255; //buff10
    //regions
    info[16] = (self >> 228 ) & 15;
    info[17] = (self >> 224 ) & 15;
    info[17] = (self >> 220 ) & 15;
    info[17] = (self >> 216 ) & 15;
    info[20] = (self >> 212 ) & 15;
    info[21] = (self >> 208 ) & 15;
    info[17] = (self >> 204 ) & 15;
    info[17] = (self >> 200 ) & 15;
    //rarity
    info[24] = (self >> 232 ) & 255;

    return info;

  }

}
  

contract A1_PaniniGame1Helper {
    

  struct A2_PlayerState {
    int256 damage;
    int256 defenderHp;//daha az islem icin.
    uint256 defenderCardIndex;
    uint256[] lifes;
    bool cardDeath;
  }

  //set playerContract
  A2_Player playerContract;
  function setA2_PlayerContract(address _address) public {  
    require(address(playerContract) == address(0) && _address != address(0) );        
    playerContract = A2_Player(_address);
  }


  //4,1,15,18
  //1426106925533459237793729347588
  //14,17,11,12
  //950737950374086236006346915854
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
      return 2*_weightRate + 800;
    } else if(_weightRate <= 300) {
      return _weightRate + 900;
    }
    return 1200; 
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
  function _cDamF(uint256 _ap, uint256 _sp, uint256 _wf, uint256 _df ) public pure returns(uint256) {
    return ( _cApF(_ap) * _cSpF(_sp) *_wf * _df) / (60000000000);//(10*600*1000*10000);
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
        int256(((_cards >> 40 ) & 1048575 )) 
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
    _c[8] = _c[8] << 120;
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
    _c[5] = _cDamF(_c[0], _c[1], _c[3], _c[2] );

    //## p2:damage factor(calcData6)
    //ap, sp -> p2
    (_c[0], _c[1]) = _cApSpBfs( _p2Cards, _c[8], _c[7]);
    //deffFactor -> p1
    _c[2] = _cDeffFBfs(_p1Cards, _c[7], _c[8]);
    _c[6] = _cDamF(_c[0], _c[1], _c[4], _c[2] );
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
       - int256((_c[5] * ((_p2Defender >> 128 ) & 255 )))
       + int256((_c[5] * ((_p1Defender >> 120 ) & 255 )))
      )/1000
    );
  }

  function getCards(uint256 _herd) internal view returns (uint256[]){
    uint256[] memory _cards = new uint256[](5);
    _cards[0] = playerContract.getCard(_herd & 4294967295);
    _cards[1] = playerContract.getCard((_herd>>32) & 4294967295);
    _cards[2] = playerContract.getCard((_herd>>64) & 4294967295);
    _cards[3] = playerContract.getCard((_herd>>96) & 4294967295);
    _cards[4] = _cards[0] + _cards[1] + _cards[2] + _cards[3];
    return _cards;

  }

  // 0 => not end.
  // 1 => player1 winner
  // 2 => player2 winner
  // 3 => draw

  //107839786687433864387751105914587979168133710367608538813840266100741
  //377439253421711279702903080799854032988620333341161505157109205958671
  function _calculateGameState(uint256 herd1, uint256 herd2, uint256 _time) public returns(uint256) {
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
    uint256[] memory calcData = new uint256[](11);
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
    

    A2_PlayerState memory p1 = A2_PlayerState(
      0, //int256 damage;
      int256((p1Cards[0] >> 100 ) & 1048575), //defenderHp
      0, //uint256 defenderCardIndex;
      _sIdxs(p1Cards),
      false//cardDeath
    );
    
    A2_PlayerState memory p2 = A2_PlayerState(
      0, //int256 damage;
      int256((p2Cards[0] >> 100 ) & 1048575), //defenderHp
      0, //uint256 defenderCardIndex;      
      _sIdxs(p2Cards),
      false//cardDeath
    );

    (p1.damage, p2.damage) = _cDmgs(calcData, regionBuffs,
      p1.defenderHp, p1Cards[0], p1Cards[4],
      p2.defenderHp, p2Cards[0], p2Cards[4] );
//iki saldiri'da ayni anda yapilacak.
    //60 => 60 sec.(1min) 
 //   for(uint256 i = game.startTime; i < _time; i = i + 60) { //time lapse :2 sec, it will be change.
    for(uint256 i = 0; i < 100; i++) { //time lapse :2 sec, it will be change.


      //####################################
      //ATTACK P1-P2 AND DAMAGE DONE
      //####################################
      if(p1.defenderHp <= p2.damage) {
        //Damage can'dan cok ise oldur.
        p1.defenderHp = 0; //defender'in olmesi durumunda defendirin oldurulmesi asagida yapilmakta.
        p1.cardDeath = true;
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
          return 3;
        } else if(p2.defenderCardIndex == 4) {
          //p1 winner
          return 1;
        }
        //p2 winner
        return 2;
      } 

    }

    return 0;
  }

}