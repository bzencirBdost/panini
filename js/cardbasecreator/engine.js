
var REGION = {
  NOURTH_AMERICA : 'region1',
  SOUTH_AMERICA : 'region2',
  EUROPE : 'region3',
  AFRICA : 'region4',
  ASIA : 'region5',
  AUSTRALIA :'region6',
  ANTARCTICA :'region7',
  OCEAN : 'region8'
}

var RARITY = {
  COMMON : 70,
  RARE : 25,
  EXOTIC : 5
}

var PASSIVE = {
  POISON :'passive1',
  HEAL_BUFF :'passive2',
  ATTACK_DEBUFF :'passive3',
  ATTACK_BUFF :'passive4',
  DEFENSE_DEBUFF :'passive5',
  DEFENSE_BUFF :'passive6',
  SPEED_DEBUFF :'passive7',
  SPEED_BUFF :'passive8',
  LIFESTEAL :'passive9',//aktive
  DAMAGE_REFLECTION :'passive10'//aktive
}

function _calculateSubOfCards(card1, card2) {
  var card = {
    name : card1.name,
    rarity : card1.rarity,
    region1: card1.region1 - card2.region1,
    region2: card1.region2 - card2.region2,
    region3: card1.region3 - card2.region3,
    region4: card1.region4 - card2.region4,
    region5: card1.region5 - card2.region5,
    region6: card1.region6 - card2.region6,
    region7: card1.region7 - card2.region7,
    region8: card1.region8 - card2.region8,
    passive1: card1.passive1 - card2.passive1,
    passive2: card1.passive2 - card2.passive2,
    passive3: card1.passive3 - card2.passive3,
    passive4: card1.passive4 - card2.passive4,
    passive5: card1.passive5 - card2.passive5,
    passive6: card1.passive6 - card2.passive6,
    passive7: card1.passive7 - card2.passive7,
    passive8: card1.passive8 - card2.passive8,
    passive9: card1.passive9 - card2.passive9,
    passive10: card1.passive10 - card2.passive10,
    hp : card1.hp - card2.hp,
    ap : card1.ap - card2.ap,
    deff : card1.deff - card2.deff,
    speed : card1.speed - card2.speed,
    weight : card1.weight - card2.weight,
    lifespan : card1.lifespan - card2.lifespan
  };
  return card;
}

function _calculateSumOfCards(card1, card2, card3, card4) {
  var card = {
    name : card1.name,
    rarity : card1.rarity,
    region1: card1.region1 + card2.region1 + card3.region1 + card4.region1,
    region2: card1.region2 + card2.region2 + card3.region2 + card4.region2,
    region3: card1.region3 + card2.region3 + card3.region3 + card4.region3,
    region4: card1.region4 + card2.region4 + card3.region4 + card4.region4,
    region5: card1.region5 + card2.region5 + card3.region5 + card4.region5,
    region6: card1.region6 + card2.region6 + card3.region6 + card4.region6,
    region7: card1.region7 + card2.region7 + card3.region7 + card4.region7,
    region8: card1.region8 + card2.region8 + card3.region8 + card4.region8,
    passive1: card1.passive1 + card2.passive1 + card3.passive1 + card4.passive1,
    passive2: card1.passive2 + card2.passive2 + card3.passive2 + card4.passive2,
    passive3: card1.passive3 + card2.passive3 + card3.passive3 + card4.passive3,
    passive4: card1.passive4 + card2.passive4 + card3.passive4 + card4.passive4,
    passive5: card1.passive5 + card2.passive5 + card3.passive5 + card4.passive5,
    passive6: card1.passive6 + card2.passive6 + card3.passive6 + card4.passive6,
    passive7: card1.passive7 + card2.passive7 + card3.passive7 + card4.passive7,
    passive8: card1.passive8 + card2.passive8 + card3.passive8 + card4.passive8,
    passive9: card1.passive9 + card2.passive9 + card3.passive9 + card4.passive9,
    passive10: card1.passive10 + card2.passive10 + card3.passive10 + card4.passive10,
    hp : card1.hp + card2.hp + card3.hp + card4.hp,
    ap : card1.ap + card2.ap + card3.ap + card4.ap,
    deff : card1.deff + card2.deff + card3.deff + card4.deff,
    speed : card1.speed + card2.speed + card3.speed + card4.speed,
    weight : card1.weight + card2.weight + card3.weight + card4.weight,
    lifespan : card1.lifespan + card2.lifespan + card3.lifespan + card4.lifespan
  };
  return card;
}


//returns 800 - 1200  : 1k = 1.
function _calculateWeightFactor(_weight1, _weight2 ) {
  //kusurat icin *1000    
  var w = (_weight1*100) / _weight2; 
  if(w <= 50) {
    return 2*w + 800;
  } else if(w <= 300) {
    return w + 900;
  }
  return 1200; 
}

// 0-1000(for %0-100). no limit.
function _calculateDeffFactor( _deff ) {
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
function _calculateDamage(_ap, _sp, _wf, _df ) {
  return (_ap*_sp*_wf) / (150*_df);//x10 df //15000 idi.
}


function PaniniGameEngine() {
  this.cards = [];
  this.cards.push({empty: 0});//index.
}

PaniniGameEngine.PASSIVE = PASSIVE;
PaniniGameEngine.REGION = REGION;
PaniniGameEngine.RARITY = RARITY;

PaniniGameEngine.prototype.printCards = function( ) {
  //console.log('name       hp  ap  deff  speed  weight  lifespan  pasives  pasivePercents  region  rarity');
  for(var i = 1; i < this.cards.length; i++) {
    var card = this.cards[i];
    var region;
    if(card.region1) {
      region = 'NOURTH_AMERICA';
    } else if(card.region2) {
      region = 'SOUTH_AMERICA';
    } else if(card.region3) {
      region = 'EUROPE';
    } else if(card.region4) {
      region = 'AFRICA';
    } else if(card.region5) {
      region = 'ASIA';
    } else if(card.region6) {
      region = 'AUSTRALIA';
    } else if(card.region7) {
      region = 'ANTARCTICA';
    } else if(card.region8) {
      region = 'OCEAN';
    }
    var passive;
    var passivePercent;
    if(card.passive1) {

    } else if(card.passive1) {
      passive = 'POISON';
      passivePercent = card.passive1;
    } else if(card.passive2) {
      passive = 'HEAL_BUFF';
      passivePercent = card.passive2;
    } else if(card.passive3) {
      passive = 'ATTACK_DEBUFF';
      passivePercent = card.passive3;
    } else if(card.passive4) {
      passive = 'ATTACK_BUFF';
      passivePercent = card.passive4;
    } else if(card.passive5) {
      passive = 'DEFENSE_DEBUFF';
      passivePercent = card.passive5;
    } else if(card.passive6) {
      passive = 'DEFENSE_BUFF';
      passivePercent = card.passive6;
    } else if(card.passive7) {
      passive = 'SPEED_DEBUFF';
      passivePercent = card.passive7;
    } else if(card.passive8) {
      passive = 'SPEED_BUFF';
      passivePercent = card.passive8;
    } else if(card.passive9) {
      passive = 'LIFESTEAL';
      passivePercent = card.passive9;
    } else if(card.passive10) {
      passive = 'DAMAGE_REFLECTION';
      passivePercent = card.passive10;
    }

    console.log();
    console.log(
      card.name + '(' + region + ')');
    console.log(
     'hp:'+ card.hp + ' '
     + 'ap:'+ card.ap + ' '
     + 'deff:'+ card.deff + ' '
     + 'speed:'+ card.speed + ' '
     + 'weight:'+ card.weight + ' '
     + 'life:'+ card.lifespan 
     +  ' passive(' + passive + '):'
     + passivePercent
    );
  }
}

PaniniGameEngine.prototype.killedCard = function(card) {
  return {
    name : card.name,
    rarity : card.rarity,
    region1: 0,
    region2: 0,
    region3: 0,
    region4: 0,
    region5: 0,//asia
    region6: 0,
    region7: 0,
    region8: 0,
    passive1: 0,
    passive2: 0,//hea
    passive3: 0,
    passive4: 0,//ap
    passive5: 0,//ddeff
    passive6: 0,//deff
    passive7: 0,
    passive8: 0,//sp
    passive9: 0,
    passive10: 0,    
    hp : 0,
    ap : 0,
    deff : 0,
    speed : 0,
    weight : 0,
    lifespan : 0
  };
} 
PaniniGameEngine.prototype.addCard = function( name, 
  hp, ap, deff, speed, weight, lifespan,
  pasives, pasivePercents, 
  region, rarity) {

  var card = {
    name : name,
    rarity : rarity,
    region1: 0,
    region2: 0,
    region3: 0,
    region4: 0,
    region5: 1,//asia
    region6: 0,
    region7: 0,
    region8: 0,
    passive1: 0,
    passive2: 0,
    passive3: 0,
    passive4: 0,
    passive5: 0,
    passive6: 5,//deff
    passive7: 0,
    passive8: 0,
    passive9: 0,
    passive10: 0,    
    hp : hp,
    ap : ap,
    deff : deff,
    speed : speed,
    weight : weight,
    lifespan : lifespan
  }

  //region olayi.
  card[region] = 1;
  for(var i = 0; i < pasives.length; i++) {
    card[pasives[i]] = pasivePercents[i];
  }
  this.cards.push(card);
}
 
function _sortedIndexs(arr)  {
  //arr : a,b,c,d
  var indexs = [];//4->temp. + index when using.
  if(arr[0].lifespan < arr[1].lifespan) {
      indexs[0] = 0;
      indexs[1] = 1;
  } else {
      indexs[0] = 1;
      indexs[1] = 0;
  }//[x,y] x<y (z = min(a,b), t = max(a,b) )

  if(arr[2].lifespan < arr[3].lifespan) {
      indexs[2] = 2;
      indexs[3] = 3;
  } else {
      indexs[2] = 3;
      indexs[3] = 2;
  }//[z,t] z<t (z = min(c,d), t = max(c,d) )

  //son case.
  //not://y<z =< x,y,z,t //bisey yapmaya gerek yok.

  //t<x => z<t < x<y
  if(arr[indexs[3]].lifespan < arr[indexs[0]].lifespan) {
      indexs[4] = indexs[0];//temp
      indexs[0] = indexs[2];
      indexs[2] = indexs[4];
      indexs[4] = indexs[1];//temp
      indexs[1] = indexs[3];
      indexs[3] = indexs[4];
  } 
  //z<x => z,x,y,t | z,x,t,y (her zaman z<y)
  else if(arr[indexs[2]].lifespan < arr[indexs[0]].lifespan) {
    //t<y => z,x,t,y
    if(arr[indexs[3]].lifespan < arr[indexs[1]].lifespan) {
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
  else if(arr[indexs[3]].lifespan < arr[indexs[1]].lifespan) {
    indexs[4] = indexs[1];//temp
    indexs[1] = indexs[2];
    indexs[2] = indexs[3];
    indexs[3] = indexs[4];
  } 
  //y<t => x<z<y<t | 
  else if(arr[indexs[2]].lifespan < arr[indexs[1]].lifespan) {
    indexs[4] = indexs[1];//temp
    indexs[1] = indexs[2];
    indexs[2] = indexs[4];
  }
  //else x<y<z<t
  indexs[4] = 0; //index of start.
  return indexs; 
}
    

//{
//    card1, card2, card3, card4, card5, card6, card7, card8
//  }, {
//    card1, card2, card3, card4, card5, card6, card7, card8
//  } 
PaniniGameEngine.prototype.StartGame = function(herd1, herd2) {

  //player1 data
  //region -> p1ActiveCards'da
  //buffs -> p1PassiveCards'da 
  //5. index sum of 1-4
  var p1ActiveCards = []; 
  p1ActiveCards[0] = this.cards[herd1.card1];
  p1ActiveCards[1] = this.cards[herd1.card2];
  p1ActiveCards[2] = this.cards[herd1.card3];
  p1ActiveCards[3] = this.cards[herd1.card4];
  p1ActiveCards[4] = _calculateSumOfCards(p1ActiveCards[0], p1ActiveCards[1], p1ActiveCards[2], p1ActiveCards[3]);
  console.log(p1ActiveCards[4]);
  
  var p1PassiveCards = []; 
  p1PassiveCards[0] = this.cards[herd1.card5];
  p1PassiveCards[1] = this.cards[herd1.card6];
  p1PassiveCards[2] = this.cards[herd1.card7];
  p1PassiveCards[3] = this.cards[herd1.card8];
  p1PassiveCards[4] = _calculateSumOfCards(p1PassiveCards[0], p1PassiveCards[1], p1PassiveCards[2], p1PassiveCards[3]);

  var p2ActiveCards = []; 
  p2ActiveCards[0] = this.cards[herd2.card1];
  p2ActiveCards[1] = this.cards[herd2.card2];
  p2ActiveCards[2] = this.cards[herd2.card3];
  p2ActiveCards[3] = this.cards[herd2.card4];
  p2ActiveCards[4] = _calculateSumOfCards(p2ActiveCards[0], p2ActiveCards[1], p2ActiveCards[2], p2ActiveCards[3]);
  console.log(p2ActiveCards[4]);

  var p2PassiveCards = []; 
  p2PassiveCards[0] = this.cards[herd2.card5];
  p2PassiveCards[1] = this.cards[herd2.card6];
  p2PassiveCards[2] = this.cards[herd2.card7];
  p2PassiveCards[3] = this.cards[herd2.card8];
  p2PassiveCards[4] = _calculateSumOfCards(p2PassiveCards[0], p2PassiveCards[1], p2PassiveCards[2], p2PassiveCards[3]);

  var p1 = {
    deffFactor :0, //uint256 deffFactor;
    damage : 0, //uint256 damage;
    defenderCardIndex : 0, //uint256 defenderCardIndex;
    defenderHp : p1ActiveCards[0].hp, //defenderHp
    ap : p1ActiveCards[4].ap,   //uint256 ap;
    sp : p1ActiveCards[4].speed,  //uint256 sp;
    deff : p1ActiveCards[4].deff,   //uint256 deff;
    weight : p1ActiveCards[4].weight,  //uint256 weight;
    aktiveCardDeath : false,
    passiveCardDeath : false
    };
  
  var p2 = {
    deffFactor :0, //uint256 deffFactor;
    damage : 0, //uint256 damage;
    defenderCardIndex : 0, //uint256 defenderCardIndex;
    defenderHp : p2ActiveCards[0].hp, //defenderHp
    ap : p2ActiveCards[4].ap,   //uint256 ap;
    sp : p2ActiveCards[4].speed,  //uint256 sp;
    deff : p2ActiveCards[4].deff,   //uint256 deff;
    weight : p2ActiveCards[4].weight,  //uint256 weight;
    aktiveCardDeath : false,
    passiveCardDeath : false
    };


  //buffs ap, dap, sp, dsp, deff, ddeff
  p1.ap += (p1ActiveCards[4].ap*(p2PassiveCards[4].passive4 - p1PassiveCards[4].passive3))/1000;
  p1.deff += (p1ActiveCards[4].deff*(p2PassiveCards[4].passive6 - p1PassiveCards[4].passive5))/1000;
  p1.sp += (p1ActiveCards[4].speed*(p2PassiveCards[4].passive8 - p1PassiveCards[4].passive7))/1000;

  //buffs ap, dap, sp, dsp, deff, ddeff
  p2.ap += (p2ActiveCards[4].ap*(p1PassiveCards[4].passive4 - p2PassiveCards[4].passive3))/1000;
  p2.deff += (p2ActiveCards[4].deff*(p1PassiveCards[4].passive6 - p2PassiveCards[4].passive5))/1000;
  p2.sp += (p2ActiveCards[4].speed*(p1PassiveCards[4].passive8 - p2PassiveCards[4].passive7))/1000;



  //damage calc.
  var weightFactor1 = _calculateWeightFactor(p1.weight, p2.weight );
  var weightFactor2 = _calculateWeightFactor(p2.weight, p1.weight );
  p1.deffFactor = _calculateDeffFactor(p1.deff);
  p2.deffFactor = _calculateDeffFactor(p2.deff);
  p1.damage = _calculateDamage(p1.ap, p1.sp, weightFactor1, p2.deffFactor ) 
  + (p1ActiveCards[0].hp*(p2PassiveCards[4].passive2 - p1PassiveCards[4].passive1))/1000; //+ heal poison. 
  p2.damage = _calculateDamage(p2.ap, p2.sp, weightFactor2, p1.deffFactor );
  +(p2ActiveCards[0].hp*(p1PassiveCards[4].passive2 - p2PassiveCards[4].passive1))/1000;//+ heal poison

  //buff9:lifesteal, buff10: reflect. calculation.
  //lifesteal = pEnemy.damage - damage*lifesteal
  //reflect = damage + pEnemy.damage*reflect
  //lifeSteal
  if(p1PassiveCards[0].passive9 > 0) {
    p2.damage -= (p1.damage*p1PassiveCards[0].passive9)/1000;
  }
  if(p1PassiveCards[0].passive10 > 0) {
    p1.damage += (p2.damage*p1PassiveCards[0].passive10)/1000;
  }
    
  //damageReflection
  if(p2PassiveCards[0].passive9 > 0) {
    p1.damage -= (p2.damage*p1PassiveCards[0].passive9)/1000;
  }
  if(p2PassiveCards[0].passive10 > 0) {
    p2.damage += (p1.damage*p2PassiveCards[0].passive10)/1000;
  }

  console.log('-------');
  console.log('p1-p2');
  console.log('weightFactor1:' + weightFactor1);
  console.log('weightFactor2:' + weightFactor2);
  console.log('-------');
  console.log(p1);
  console.log('-------');
  console.log(p2);
  console.log('-------');

  //####
  //life span hesaplama.
  //####  
  var p1ALifes = _sortedIndexs(p1ActiveCards);
  var p1PLifes = _sortedIndexs(p1PassiveCards);
  var p2ALifes = _sortedIndexs(p2ActiveCards);
  var p2PLifes = _sortedIndexs(p2PassiveCards);

  for(var i = 1; i < 1000; i++) {
    //console.log('p1.damage' + p1.damage);
    //console.log('p2.damage' + p2.damage);

    //yasam suresi biten olursa oldur.
    console.log('----------------------------------------------------------');
    console.log('>>>>>  life of p1 aktiveCard-'   +  p1ALifes[p1ALifes[4]] + '('+ i + '/'+ p1ActiveCards[p1ALifes[p1ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p1.defenderCardIndex + ' defenderHp: (' + p1.defenderHp +'/' + p1ActiveCards[p1.defenderCardIndex].hp + ')  damage: ' + p1.damage );
    console.log('>>>>>  life of p2 aktiveCard-'   +  p2ALifes[p2ALifes[4]] + '('+ i + '/'+ p2ActiveCards[p2ALifes[p2ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p2.defenderCardIndex + ' defenderHp: (' + p2.defenderHp +'/' + p2ActiveCards[p2.defenderCardIndex].hp + ')  damage: ' + p2.damage );
    if(p1ActiveCards[p1ALifes[p1ALifes[4]]].lifespan <= i) {
      //olen defender mi?
      //bu turun sonunda oluyor aslinda(damagesini yapiyor.).
      if(p1ALifes[p1ALifes[4]] == p1.defenderCardIndex) {
        p1.defenderHp = 0;
      } else {
        p1ActiveCards[p1ALifes[p1ALifes[4]]] = _calculateSubOfCards( p1ActiveCards[4], p1ActiveCards[p1ALifes[p1ALifes[4]]]);  
        p1ActiveCards[p1ALifes[p1ALifes[4]]] = this.killedCard(p1ActiveCards[p1ALifes[p1ALifes[4]]]);
      }
      p1ALifes[4] += 1;
      //sonraki kart eger savasta olmus kart ise tekrar tekrar damage hesaplmasin sonraki turlarda
      if(p1ALifes[p1ALifes[4]] < p1.defenderCardIndex) {
        p1ALifes[4] += 1
        if(p1ALifes[p1ALifes[4]] < p1.defenderCardIndex) {
          p1ALifes[4] += 1
        }
      }
      p1.aktiveCardDeath = true;
    }
        
    if(p2ActiveCards[p2ALifes[p2ALifes[4]]].lifespan <= i) {
      //olen defender mi?
      //bu turun sonunda oluyor aslinda(damagesini yapiyor.).
      if(p2ALifes[p2ALifes[4]] == p2.defenderCardIndex) {
        p2.defenderHp = 0;
      } else {
        p2ActiveCards[p2ALifes[p2ALifes[4]]] = _calculateSubOfCards( p2ActiveCards[4], p2ActiveCards[p2ALifes[p2ALifes[4]]]);
        p2ActiveCards[p2ALifes[p2ALifes[4]]] = this.killedCard(p2ActiveCards[p2ALifes[p2ALifes[4]]]);
      }

      p2ALifes[4] += 1;
      //sonraki kart eger savasta olmus kart ise tekrar tekrar damage hesaplmasin sonraki turlarda
      if(p2ALifes[p2ALifes[4]] < p2.defenderCardIndex) {
        p2ALifes[4] += 1
        if(p2ALifes[p2ALifes[4]] < p2.defenderCardIndex) {
          p2ALifes[4] += 1
        }
      }
      p2.aktiveCardDeath = true;
    }

    if(p1PLifes[4] < 4 && p1PassiveCards[p1PLifes[p1PLifes[4]]].lifespan <= i) {
      p1PLifes[4] += 1;
      p1PassiveCards[4] = _calculateSubOfCards( p1PassiveCards[4],p1PassiveCards[p1PLifes[p1PLifes[4]]]);          
      p1.passiveCardDeath = true;
    }
    if(p2PLifes[4] < 4 && p2PassiveCards[p2PLifes[p2PLifes[4]]].lifespan <= i) {
      p2PLifes[4] += 1;
      p2PassiveCards[4] = _calculateSubOfCards( p2PassiveCards[4], p2PassiveCards[p2PLifes[p2PLifes[4]]]);          
      p2.passiveCardDeath = true;
    }


    //saldiri.
    if(p1.defenderHp <= p2.damage) {
      //died.
      p1ActiveCards[4] = _calculateSubOfCards( p1ActiveCards[4], p1ActiveCards[p1.defenderCardIndex]);          
      p1ActiveCards[p1.defenderCardIndex] = this.killedCard(p1ActiveCards[p1.defenderCardIndex]);

      //yasam suresi bitmemis ise arttir. //eger yasam suresi bitmisse zaten arttiramayacak.
      if(p1ALifes[p1ALifes[4]] == p1.defenderCardIndex) {
        p1ALifes[4] += 1;
        //sonraki kart eger savasta olmus kart ise tekrar tekrar damage hesaplmasin sonraki turlarda
        if(p1ALifes[p1ALifes[4]] < p1.defenderCardIndex) {
          p1ALifes[4] += 1
          if(p1ALifes[p1ALifes[4]] < p1.defenderCardIndex) {
            p1ALifes[4] += 1
          }
        }

      }

      p1.defenderHp = 0;
      p1.aktiveCardDeath = true;

    } else {
      p1.defenderHp -= p2.damage;
    }

    if(p2.defenderHp <= p1.damage) {
      //died.
      p2ActiveCards[4] = _calculateSubOfCards( p2ActiveCards[4], p2ActiveCards[p2.defenderCardIndex]);          
      p2ActiveCards[p2.defenderCardIndex] = this.killedCard(p2ActiveCards[p2.defenderCardIndex]);

      //yasam suresi bitmemis ise arttir. //eger yasam suresi bitmisse zaten arttiramayacak.
      if(p2ALifes[p2ALifes[4]] == p2.defenderCardIndex) {
        p2ALifes[4] += 1; 
        //sonraki kart eger savasta olmus kart ise tekrar tekrar damage hesaplmasin sonraki turlarda
        if(p2ALifes[p2ALifes[4]] < p2.defenderCardIndex) {
          p2ALifes[4] += 1
          if(p2ALifes[p2ALifes[4]] < p2.defenderCardIndex) {
            p2ALifes[4] += 1
          }
        }
      }

      p2.defenderHp = 0;
      p2.aktiveCardDeath = true;

    } else {
      p2.defenderHp -= p1.damage;
    }

    //if aktifCard died. Recalculate.
    //1. oyuncunun kartlari da olduyse. (ayni islemleri tekrarlamamak icin.)
    if(p1.aktiveCardDeath ) {
      
      //defender olduyse yeni defendar belirle.
      if(p1.defenderHp == 0) {

        p1.defenderCardIndex++;
        //life span ile olenleri gec.
        if(p1.defenderCardIndex < 4 && p1ActiveCards[p1.defenderCardIndex].hp == 0) {
          p1.defenderCardIndex++;
          if(p1.defenderCardIndex < 4 && p1ActiveCards[p1.defenderCardIndex].hp == 0) {
            p1.defenderCardIndex++;
           if(p1.defenderCardIndex < 4 && p1ActiveCards[p1.defenderCardIndex].hp == 0) {
              p1.defenderCardIndex++;
            }     
          }   
        }
        p1.defenderHp = p1ActiveCards[p1.defenderCardIndex].hp; //defenderHp
      }

      // oyun hala devam ediyor ise hesapla.
      if(p1.defenderCardIndex < 4) {

        p1.ap = p1ActiveCards[4].ap;  //uint256 ap;
        p1.sp = p1ActiveCards[4].speed;   //uint256 sp;
        p1.deff = p1ActiveCards[4].deff;   //uint256 weight;
        p1.weight = p1ActiveCards[4].weight;   //uint256 deff;
        
        p1.deffFactor = _calculateDeffFactor(p1.deff);          
      }        

    }

    //if aktifCard died. Recalculate.
    //2. oyuncunun kartlari da olduyse. (ayni islemleri tekrarlamamak icin.)
    if(p2.aktiveCardDeath ) {
    
      if(p2.defenderHp == 0) {

        p2.defenderCardIndex++;

        //life span ile olenleri gec.
        if(p2.defenderCardIndex < 4 && p2ActiveCards[p2.defenderCardIndex].hp == 0) {
          p2.defenderCardIndex++;
          if(p2.defenderCardIndex < 4 && p2ActiveCards[p2.defenderCardIndex].hp == 0) {
            p2.defenderCardIndex++;
           if(p2.defenderCardIndex < 4 && p2ActiveCards[p2.defenderCardIndex].hp == 0) {
              p2.defenderCardIndex++;
            }     
          }   
        }
        p2.defenderHp = p2ActiveCards[p2.defenderCardIndex].hp; //defenderHp
      }  
       // oyun hala devam ediyor ise hesapla.
      if(p2.defenderCardIndex < 4) {
        
        p2.ap = p2ActiveCards[4].ap;  //uint256 ap;
        p2.sp = p2ActiveCards[4].speed;   //uint256 sp;
        p2.deff = p2ActiveCards[4].deff;   //uint256 weight;
        p2.weight = p2ActiveCards[4].weight;   //uint256 deff;
        
        p2.deffFactor = _calculateDeffFactor(p2.deff);
      }      
    }  

    //buraya kadar:
    //olen pasif kaldirildi
    //damage yapildi
    //siradaki aktif kart belirlendi(olen var ise)
    //ap,sp vs hesaplandi.
    //buradan sonrasi:
    //her hangi bir kart olduyse ve oyun devam ediyor ise;
    //buflari ekle.
    //damageleri hesapla.
    //

    // oyun hala devam ediyor ise hesapla.
    if(p1.defenderCardIndex < 4 && p2.defenderCardIndex < 4) {

      //bir kart olduyse.
      //DAMAGE HESAPLA
      if( p1.aktiveCardDeath || p2.aktiveCardDeath || p1.passiveCardDeath || p2.passiveCardDeath ) {

        //buffs ap, dap, sp, dsp, deff, ddeff
        p1.ap += (p1ActiveCards[p1.defenderCardIndex].ap*(p2PassiveCards[4].passive4 - p1PassiveCards[4].passive3))/1000;
        p1.deff += (p1ActiveCards[p1.defenderCardIndex].deff*(p2PassiveCards[4].passive6 - p1PassiveCards[4].passive5))/1000;
        p1.sp += (p1ActiveCards[p1.defenderCardIndex].speed*(p2PassiveCards[4].passive8 - p1PassiveCards[4].passive7))/1000;

        //buffs ap, dap, sp, dsp, deff, ddeff
        p2.ap += (p2ActiveCards[p2.defenderCardIndex].ap*(p1PassiveCards[4].passive4 - p2PassiveCards[4].passive3))/1000;
        p2.deff += (p2ActiveCards[p2.defenderCardIndex].deff*(p1PassiveCards[4].passive6 - p2PassiveCards[4].passive5))/1000;
        p2.sp += (p2ActiveCards[p2.defenderCardIndex].speed*(p1PassiveCards[4].passive8 - p2PassiveCards[4].passive7))/1000;

        weightFactor1 = _calculateWeightFactor(p1.weight, p2.weight );
        weightFactor2 = _calculateWeightFactor(p2.weight, p1.weight );
        p1.damage = _calculateDamage(p1.ap, p1.sp, weightFactor1, p2.deffFactor )
          +(p1ActiveCards[p1.defenderCardIndex].hp*(p2PassiveCards[4].passive2 - p1PassiveCards[4].passive1))/1000;//heal poison
        p2.damage = _calculateDamage(p2.ap, p2.sp, weightFactor2, p1.deffFactor )
          +(p2ActiveCards[p2.defenderCardIndex].hp*(p1PassiveCards[4].passive2 - p2PassiveCards[4].passive1))/1000;//heal poison

        //buff9:lifesteal, buff10: reflect. calculation.
        //lifesteal = pEnemy.damage - damage*lifesteal
        //reflect = damage + pEnemy.damage*reflect
        //lifeSteal
        if(p1PassiveCards[p1.defenderCardIndex].passive9 > 0) {
          p2.damage -= (p1.damage*p1PassiveCards[p1.defenderCardIndex].passive9)/1000;
        }
        if(p1PassiveCards[p1.defenderCardIndex].passive10 > 0) {
          p1.damage += (p2.damage*p1PassiveCards[p1.defenderCardIndex].passive10)/1000;
        }
          
        //damageReflection
        if(p2PassiveCards[p2.defenderCardIndex].passive9 > 0) {
          p1.damage -= (p2.damage*p2PassiveCards[p2.defenderCardIndex].passive9)/1000;
        }
        if(p2PassiveCards[p2.defenderCardIndex].passive10 > 0) {
          p2.damage += (p1.damage*p2PassiveCards[p2.defenderCardIndex].passive10)/1000;
        }

        p1.aktiveCardDeath = false;
        p1.passiveCardDeath = false;

        p2.aktiveCardDeath = false;
        p2.passiveCardDeath = false;
      }
    
    } 
    //kazanma kaybetme berabere durumlari
    //berabere
    else if(p2.defenderCardIndex == 4) {
      console.log('----------------------------------------------------------');
      console.log('>>>>>  life of p1 aktiveCard-'   +  p1ALifes[p1ALifes[4]] + '('+ i + '/'+ p1ActiveCards[p1ALifes[p1ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p1.defenderCardIndex + ' defenderHp: (' + p1.defenderHp +'/' + p1ActiveCards[p1.defenderCardIndex].hp + ')  damage: ' + p1.damage );
      console.log('>>>>>  life of p2 aktiveCard-'   +  p2ALifes[p2ALifes[4]] + '('+ i + '/'+ p2ActiveCards[p2ALifes[p2ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p2.defenderCardIndex + ' defenderHp: (' + p2.defenderHp +'/' + p2ActiveCards[p2.defenderCardIndex].hp + ')  damage: ' + p2.damage );  
      console.log('The winner: player-1!');
      return 1;
    //p2 winner
    } else if(p1.defenderCardIndex == 4) {
      console.log('----------------------------------------------------------');
      console.log('>>>>>  life of p1 aktiveCard-'   +  p1ALifes[p1ALifes[4]] + '('+ i + '/'+ p1ActiveCards[p1ALifes[p1ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p1.defenderCardIndex + ' defenderHp: (' + p1.defenderHp +'/' + p1ActiveCards[p1.defenderCardIndex].hp + ')  damage: ' + p1.damage );
      console.log('>>>>>  life of p2 aktiveCard-'   +  p2ALifes[p2ALifes[4]] + '('+ i + '/'+ p2ActiveCards[p2ALifes[p2ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p2.defenderCardIndex + ' defenderHp: (' + p2.defenderHp +'/' + p2ActiveCards[p2.defenderCardIndex].hp + ')  damage: ' + p2.damage );        return 2;
      console.log('The winner: player-2!');
    } else {  
      console.log('----------------------------------------------------------');
      console.log('>>>>>  life of p1 aktiveCard-'   +  p1ALifes[p1ALifes[4]] + '('+ i + '/'+ p1ActiveCards[p1ALifes[p1ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p1.defenderCardIndex + ' defenderHp: (' + p1.defenderHp +'/' + p1ActiveCards[p1.defenderCardIndex].hp + ')  damage: ' + p1.damage );
      console.log('>>>>>  life of p2 aktiveCard-'   +  p2ALifes[p2ALifes[4]] + '('+ i + '/'+ p2ActiveCards[p2ALifes[p2ALifes[4]]].lifespan + ')  defenderCardIndex:'  + p2.defenderCardIndex + ' defenderHp: (' + p2.defenderHp +'/' + p2ActiveCards[p2.defenderCardIndex].hp + ')  damage: ' + p2.damage );
      console.log('Draw!');
        return 3;
    }
  }//end of loop
  return 0;
}


module.exports = PaniniGameEngine;


//

/*

function toHex (decimal, size) {
  var res = parseInt(''+ decimal).toString(16);
  var n = res.length;
  for(var i = 0; i < size - n; i++) {res = '0' + res;}
  return res;
}


//hp, ap, deff, speed, weight, lifespan, 
//  passive, passivePercent, region, rarity
function build256BitStringFrom(cardBase) {
  var res =''
    + toHex(cardBase.rarity, 2)    
    + toHex(cardBase.region1, 1)    
    + toHex(cardBase.region2, 1)    
    + toHex(cardBase.region3, 1)    
    + toHex(cardBase.region4, 1)    
    + toHex(cardBase.region5, 1)    
    + toHex(cardBase.region6, 1)    
    + toHex(cardBase.region7, 1)    
    + toHex(cardBase.region8, 1)    
    + toHex(cardBase.passive1, 2)    
    + toHex(cardBase.passive2, 2)    
    + toHex(cardBase.passive3, 2)    
    + toHex(cardBase.passive4, 2)    
    + toHex(cardBase.passive5, 2)    
    + toHex(cardBase.passive6, 2)    
    + toHex(cardBase.passive7, 2)    
    + toHex(cardBase.passive8, 2)    
    + toHex(cardBase.passive9, 2)    
    + toHex(cardBase.passive10, 2)    
    + toHex(cardBase.hp, 5)
    + toHex(cardBase.ap, 5)
    + toHex(cardBase.deff, 5)
    + toHex(cardBase.speed, 5)
    + toHex(cardBase.weight, 5)
    + toHex(cardBase.lifespan, 5);
  return '0x' + res;
}

function buildObjectFrom256Bit(hex64) {
  var obj = {};
  var n = hex64.length -1;
  var k = 0;

  var elem = '';

  //features
  for(var i = 0; i < 5;i++) {elem = hex64[n-k] + elem;k++;}
  obj.lifespan = parseInt(elem, 16); elem = '';
  for(var i = 0; i < 5;i++) {elem = hex64[n-k] + elem;k++;}
  obj.weight = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 5;i++) {elem = hex64[n-k] + elem;k++;}
  obj.speed = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 5;i++) {elem = hex64[n-k] + elem;k++;}
  obj.deff = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 5;i++) {elem = hex64[n-k] + elem;k++;}
  obj.ap = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 5;i++) {elem = hex64[n-k] + elem;k++;}
  obj.hp = parseInt(elem, 16);
  //passive
  for(var i = 0; i < 20;i++) {elem = hex64[n-k] + elem;k++;}
  obj.passive = parseInt(elem, 16); elem = '';
  //region
  for(var i = 0; i < 8;i++) {elem = hex64[n-k] + elem;k++;}
  obj.region = parseInt(elem, 16); elem = '';
  //rarity
  for(var i = 0; i < 2;i++) {elem = hex64[n-k] + elem;k++;}
  obj.rarity = parseInt(elem, 16); elem = '';
  
  //sirasini tekrar saglamak icin(objenin.)
  return {
    rarity : obj.rarity, 
    region : obj.region, 
    passive : obj.passive, 
    hp : obj.hp, 
    ap: obj.ap,
    deff: obj.deff,
    speed: obj.speed,
    weight: obj.weight,
    lifespan: obj.lifespan
  }
}

var objFil = {
  rarity: 70,
  region1: 0,
  region2: 0,
  region3: 0,
  region4: 0,
  region5: 1,//asia
  region6: 0,
  region7: 0,
  region8: 0,
  passive1: 0,
  passive2: 0,
  passive3: 0,
  passive4: 0,
  passive5: 0,
  passive6: 5,//deff
  passive7: 0,
  passive8: 0,
  passive9: 0,
  passive10: 0,
  hp : 10000, 
  ap: 1000,
  deff: 300,
  speed: 80,
  weight: 6000,
  lifespan: 60
};

var objAt = {
  rarity: 70,
  region1: 0,
  region2: 0,
  region3: 0,
  region4: 0,
  region5: 1,//asia
  region6: 0,
  region7: 0,
  region8: 0,
  passive1: 0,
  passive2: 0,
  passive3: 0,
  passive4: 0,
  passive5: 0,
  passive6: 0,//deff
  passive7: 0,
  passive8: 5,//speed
  passive9: 0,
  passive10: 0,
  hp : 700, 
  ap: 30,
  deff: 120,
  speed: 120,
  weight: 500,
  lifespan: 30
};

var objTavsan = {
  rarity: 70,
  region1: 0,
  region2: 0,
  region3: 1,//eu
  region4: 0,
  region5: 0,//asia
  region6: 0,
  region7: 0,
  region8: 0,
  passive1: 0,
  passive2: 0,
  passive3: 0,
  passive4: 0,
  passive5: 0,
  passive6: 0,//deff
  passive7: 0,
  passive8: 0,//speed
  passive9: 0,
  passive10: 10,//lf buff
  hp : 20, 
  ap: 30,
  deff: 20,
  speed: 50,
  weight: 2,
  lifespan: 6
};

var objAslan = {
  rarity: 25,
  region1: 0,
  region2: 0,
  region3: 0,//eu
  region4: 1,//af
  region5: 0,//asia
  region6: 0,
  region7: 0,
  region8: 0,
  passive1: 0,
  passive2: 0,
  passive3: 0,
  passive4: 10,//ap
  passive5: 0,
  passive6: 0,//deff
  passive7: 0,
  passive8: 0,//speed
  passive9: 0,
  passive10: 10,//lf buff
  hp : 1000, 
  ap: 500,
  deff: 300,
  speed: 70,
  weight: 250,
  lifespan: 20
};

var objBalina = {
  rarity: 25,
  region1: 0,
  region2: 0,
  region3: 0,//eu
  region4: 0,//af
  region5: 0,//asia
  region6: 0,
  region7: 0,
  region8: 1,//oc
  passive1: 0,
  passive2: 10,//hp
  passive3: 0,
  passive4: 0,//ap
  passive5: 0,
  passive6: 0,//deff
  passive7: 0,
  passive8: 0,//speed
  passive9: 0,
  passive10: 10,//lf buff
  hp : 5000, 
  ap: 10,
  deff: 100,
  speed: 60,
  weight: 30000,
  lifespan: 120
};      

var objYunus = {
  rarity: 25,
  region1: 0,
  region2: 0,
  region3: 0,//eu
  region4: 0,//af
  region5: 0,//asia
  region6: 0,
  region7: 0,
  region8: 1,//oc
  passive1: 0,
  passive2: 10,//hp
  passive3: 0,
  passive4: 0,//ap
  passive5: 0,
  passive6: 0,//deff
  passive7: 0,
  passive8: 0,//speed
  passive9: 0,
  passive10: 0,//lf buff
  hp : 100, 
  ap: 30,
  deff: 100,
  speed: 100,
  weight: 200,
  lifespan: 40
};      
var objKilicBaligi = {
  rarity: 5,
  region1: 0,
  region2: 0,
  region3: 0,//eu
  region4: 0,//af
  region5: 0,//asia
  region6: 0,
  region7: 0,
  region8: 1,//oc
  passive1: 0,
  passive2: 0,//hp
  passive3: 0,
  passive4: 0,//ap
  passive5: 10,//dedeff
  passive6: 0,//deff
  passive7: 0,
  passive8: 0,//speed
  passive9: 0,
  passive10: 0,//lf buff
  hp : 60, 
  ap: 120,
  deff: 200,
  speed: 120,
  weight: 50,
  lifespan: 30
};      

var objKartal = {
  rarity: 25,
  region1: 0,
  region2: 0,
  region3: 0,//eu
  region4: 0,//af
  region5: 1,//asia
  region6: 0,
  region7: 0,
  region8: 0,//oc
  passive1: 0,
  passive2: 0,//hp
  passive3: 0,
  passive4: 0,//ap
  passive5: 0,//dedeff
  passive6: 0,//deff
  passive7: 0,
  passive8: 10,//speed
  passive9: 0,
  passive10: 0,//lf buff
  hp : 20, 
  ap: 100,
  deff: 80,
  speed: 120,
  weight: 20,
  lifespan: 20
};      


var objGuvercin = {
  rarity: 75,
  region1: 0,
  region2: 1,//na
  region3: 0,//eu
  region4: 0,//af
  region5: 0,//asia
  region6: 0,
  region7: 0,
  region8: 0,//oc
  passive1: 0,
  passive2: 10,//hp
  passive3: 0,
  passive4: 0,//ap
  passive5: 10,//dedeff
  passive6: 0,//deff
  passive7: 0,
  passive8: 0,//speed
  passive9: 0,
  passive10: 0,//lf buff
  hp : 20, 
  ap: 100,
  deff: 80,
  speed: 120,
  weight: 20,
  lifespan: 20
}; 


var objKarinca = {
  rarity: 75,
  region1: 0,
  region2: 0,//na
  region3: 0,//eu
  region4: 0,//af
  region5: 0,//asia
  region6: 1,//au
  region7: 0,
  region8: 0,//oc
  passive1: 0,
  passive2: 0,//hp
  passive3: 0,
  passive4: 0,//ap
  passive5: 20,//dedeff
  passive6: 0,//deff
  passive7: 0,
  passive8: 0,//speed
  passive9: 0,
  passive10: 0,//lf buff
  hp : 1, 
  ap: 1,
  deff: 1,
  speed: 1,
  weight: 0,
  lifespan: 3
}; 

console.log(JSON.stringify(objFil));

var bit256 = build256BitStringFrom(objFil);
console.log(bit256);
bit256 = build256BitStringFrom(objBalina);
console.log(bit256);
bit256 = build256BitStringFrom(objKarinca);
console.log(bit256);
bit256 = build256BitStringFrom(objGuvercin);
console.log(bit256);
bit256 = build256BitStringFrom(objKartal);
console.log(bit256);
bit256 = build256BitStringFrom(objYunus);
console.log(bit256);
bit256 = build256BitStringFrom(objAslan);
console.log(bit256);
bit256 = build256BitStringFrom(objTavsan);
console.log(bit256);
bit256 = build256BitStringFrom(objAt);
console.log(bit256);
bit256 = build256BitStringFrom(objKilicBaligi);
console.log(bit256);

var obj = buildObjectFrom256Bit('460000100000000000000000050000002BC0001E0007800078001F40001E');
console.log(JSON.stringify(obj));







/*
Microsoft Windows [Version 6.3.9600]
(c) 2013 Microsoft Corporation. Tüm hakları saklıdır.

C:\Users\baris>cd ethprojects

C:\Users\baris\ethprojects>cd cardbasecreator

C:\Users\baris\ethprojects\cardbasecreator>node app.js
Base Card Creater.
{"rarity":70,"region1":0,"region2":0,"region3":0,"region4":0,"region5":1,"region
6":0,"region7":0,"region8":0,"passive1":0,"passive2":0,"passive3":0,"passive4":0
,"passive5":0,"passive6":5,"passive7":0,"passive8":0,"passive9":0,"passive10":0,
"hp":10000,"ap":1000,"deff":300,"speed":80,"weight":6000,"lifespan":60}
0x46000010000000000000050000000002710003e80012c00050017700003c
0x1900000001000a000000000000000a013880000a000640003c0753000078
0x4b0000010000000000140000000000000010000100001000010000000003
0x4b01000000000a00000a0000000000000140006400050000780001400014
0x1900001000000000000000000a0000000140006400050000780001400014
0x1900000001000a0000000000000000000640001e0006400064000c800028
0x19000100000000000a00000000000a003e8001f40012c00046000fa00014
0x46001000000000000000000000000a000140001e00014000320000200006
0x460000100000000000000000050000002bc0001e0007800078001f40001e
0x0500000001000000000a00000000000003c00078000c800078000320001e

C:\Users\baris\ethprojects\cardbasecreator>


C:\Users\baris\ethprojects\cardbasecreator>node app.js
Base Card Creater.
{"rarity":70,"region1":0,"region2":0,"region3":0,"region4":0,"region5":1,"region
6":0,"region7":0,"region8":0,"passive1":0,"passive2":0,"passive3":0,"passive4":0
,"passive5":0,"passive6":5,"passive7":0,"passive8":0,"passive9":0,"passive10":0,
"hp":10000,"ap":1000,"deff":300,"speed":80,"weight":6000,"lifespan":60}
0x46000010000000000000050000000002710003e80012c00050017700003c

{"rarity":70,"region":4096,"passive":22517998136862480,"hp":10000,"ap":1000,"def
f":300,"speed":80,"weight":6000,"lifespan":60}




function toHex (decimal, size) {
  var res = parseInt(''+ decimal).toString(16);
  var n = res.length;
  for(var i = 0; i < size - n; i++) {res = '0' + res;}
  return res;
}


//hp, ap, deff, speed, weight, lifespan, 
//  passive, passivePercent, region, rarity
function build256BitStringFrom(cardBase) {
  var res =''
    + toHex(cardBase.hp, 4)
    + toHex(cardBase.ap, 4)
    + toHex(cardBase.deff, 4)
    + toHex(cardBase.speed, 4)
    + toHex(cardBase.weight, 4)
    + toHex(cardBase.lifespan, 4)
    + toHex(cardBase.passive, 2)
    + toHex(cardBase.passivePercent, 4)
    + toHex(cardBase.region, 2)
    + toHex(cardBase.rarity, 4);    
  return '0x' + res;
}

function buildObjectFrom256Bit(hex64) {
  var obj = {};
  var n = hex64.length -1;
  var k = 0;

  var elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.rarity = parseInt(elem, 16); elem = '';
  for(var i = 0; i < 2;i++) {elem = hex64[n-k] + elem;k++;}
  obj.region = parseInt(elem, 16); elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.passivePercent = parseInt(elem, 16); elem = '';
  for(var i = 0; i < 2;i++) {elem = hex64[n-k] + elem;k++;}
  obj.passive = parseInt(elem, 16); elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.lifespan = parseInt(elem, 16); elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.weight = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.speed = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.deff = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.ap = parseInt(elem, 16);elem = '';
  for(var i = 0; i < 4;i++) {elem = hex64[n-k] + elem;k++;}
  obj.hp = parseInt(elem, 16);
  
  //sirasini tekrar saglamak icin(objenin.)
  return {
    hp : obj.hp, 
    ap: obj.ap,
    deff: obj.deff,
    speed: obj.speed,
    weight: obj.weight,
    lifespan: obj.lifespan,
    passive: obj.passive,
    passivePercent: obj.passivePercent,
    region: obj.region,
    rarity: obj.rarity
  }
}

var objFil = {
  hp : 10000, 
  ap: 1000,
  deff: 300,
  speed: 80,
  weight: 6000,
  lifespan: 60,
  passive: 2,
  passivePercent: 5,
  region: 2,
  rarity: 70
};
console.log(JSON.stringify(objFil));

var bit256 = build256BitStringFrom(objFil);
console.log(bit256);

var obj = buildObjectFrom256Bit(bit256);
console.log(JSON.stringify(obj));



Test1:
C:\Users\baris\ethprojects\cardbasecreator>node app.js
Base Card Creater.
{"hp":10000,"ap":1000,"deff":300,"speed":80,"weight":6000,"lifespan":60,"passive
":2,"passivePercent":5,"region":2,"rarity":70}
0x271003e8012c00501770003c020005020046
{"hp":10000,"ap":1000,"deff":300,"speed":80,"weight":6000,"lifespan":60,"passive
":2,"passivePercent":5,"region":2,"rarity":70}

C:\Users\baris\ethprojects\cardbasecreator>




/*



  //data
  struct Data {

    //kullanilmayacak, bunun yerine indexler id olacak.
    uint256 id; // arr index: 0: empty initialized and never used.
    string name;
    
    uint256 hp; //health power
    uint256 ap; //attack power
    uint256 deff; //defence
    uint256 speed; //speed
    uint256 weight; //weight
    uint256 lifespan; //life span    

    uint256 region;
    uint256 rarity; // 0-100 arasinda bir sayi. 

    //pasif ozellikler
    uint256 passive;
    uint256 passivePercent; // 10 = %10
  }

#id olmayacak.
#name olmayacak. serverda farkli dillere fakli isimler verilebilir.

#hp: 0-32k 16 bit
#ap: 0-32k 16 bit
#deff: 0-32k 16 bit
#speed: 0-32k 16 bit
#weight: 0-32k 16 bit
#lifespan: 0-32k 16 bit

#passive: 0-256 8 bit
#passivePercent: 0-32k 16 bit

#region: 0-256 8 bit
#rarity: 0-32k 16 bit
*/







/*

function toBinary16 (decimal) {
  var res = parseInt(''+ decimal).toString(2);
  var n = res.length;
  for(var i = 0; i < 16 - n; i++) {
    res = '0' + res;
  }
  return res;
}

function toBinary8 (decimal) {
  var res = parseInt(''+ decimal).toString(2);
  var n = res.length;
  for(var i = 0; i < 8 - n; i++) {
    res = '0' + res;
  }
  return res;
}
var res = toBinary8(15);
console.log('y000100010001000x000100010001000x000100010001000x000100010001000y000100010001000x000100010001000x000100010001000x000100010001000y000100010001000x000100010001000x000100010001000x000100010001000y000100010001000x000100010001000x000100010001000x000100010001000');
console.log(res);

function build256BitStringFrom(hp, ap, deff, speed, weight, lifespan, 
  passive, passivePercent, region, rarity) {
  var res =''
    + toBinary16(hp)
    + toBinary16(ap)
    + toBinary16(deff)
    + toBinary16(speed)
    + toBinary16(weight)
    + toBinary16(lifespan)
    + toBinary8(passive)
    + toBinary16(passivePercent)
    + toBinary8(region)
    + toBinary16(rarity);  
  var n = res.length;
  for(var i = 0; i < 256 - n; i++) {
    res = '0' + res;
  }
  return res;
}

function buildObjectFrom256Bit(bit256) {
  var obj = {};
  var n = 255;
  var k = 0;

  var elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.rarity = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 8;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.region = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.passivePercent = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 8;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.passive = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.lifespan = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.weight = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.speed = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.deff = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.ap = parseInt(elem, 2);

  elem = '';
  for(var i = 0; i < 16;i++) {
    elem = bit256[n-k] + elem;
    k++;
  }
  obj.hp = parseInt(elem, 2);




  return obj;
}

var bit256 = build256BitStringFrom(
  10000, 1000, 300, 80, 6000, 60, 
  2, 60, 4, 2, 70 
  );
console.log(bit256);
var obj = buildObjectFrom256Bit(bit256);
console.log(JSON.stringify(obj));


/*

function binaryToDecimal (binary) {
  return parseInt(binary, 2);
}

function Mask16BitRightShift(n) {
  var mask16 = 65535;
  return mask16 << (n*16);  
}
console.log(3 << 2);

var mask = Mask16BitRightShift(2);
console.log(mask);
var binary = decimalToBinary(mask);
console.log(binary);

/*

//test
var number = Math.pow(2, 16);
console.log(number);
var binary = decimalToBinary(number);
console.log(binary);
var decimal = binaryToDecimal(MASKS.BIT16);
console.log(decimal);
*/
//shift test
