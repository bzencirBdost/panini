//####################
//        TEST
//####################
var PaniniGameEngine = require('./engine.js');
console.log(PaniniGameEngine);
var engine = new PaniniGameEngine();
var PASSIVE = PaniniGameEngine.PASSIVE;
var REGION = PaniniGameEngine.REGION;
var RARITY = PaniniGameEngine.RARITY;
  //addCard = function( name, 
  //hp, ap, deff, speed, weight, lifespan, 
  //pasives, pasivePercents, 
  // region, rarity );
  // sp , wei, len, lifespan, 
//1
engine.addCard('Black Bear', 
  //hp, ap, deff, sp, we, life, 
  1000, 150, 200, 50, 190, 26, 
  [PASSIVE.ATTACK_BUFF] , [100],
  REGION.NOURTH_AMERICA, RARITY.COMMON);

//2
engine.addCard('Raccoon', 
  //hp, ap, deff, sp, we, life, 
  80, 20, 20, 24, 6, 14, 
  [PASSIVE.LIFESPAN_BUFF ] , [70],
  REGION.NOURTH_AMERICA, RARITY.COMMON);

//3
engine.addCard('Mustang', 
  //hp, ap, deff, sp, we, life, 
  150, 40, 50, 75, 600, 19, 
  [PASSIVE.SPEED_BUFF ] , [120],
  REGION.NOURTH_AMERICA, RARITY.EXOTIC);

//4
engine.addCard('American Bison', 
  //hp, ap, deff, sp, we, life, 
  1500, 100, 300, 35, 1200, 17, 
  [PASSIVE.DEFENSE_BUFF ] , [140],
  REGION.NOURTH_AMERICA, RARITY.RARE);

//5
engine.addCard('Mountain Lion', 
  //hp, ap, deff, sp, we, life, 
  600, 200, 150, 40, 220, 15, 
  [PASSIVE.ATTACK_BUFF ] , [50],
  REGION.NOURTH_AMERICA, RARITY.EXOTIC); //exotic olmali?

//6
engine.addCard('Bald Eagle', 
  //hp, ap, deff, sp, we, life, 
  100, 100, 50, 150, 7, 18, 
  [PASSIVE.SPEED_BUFF ] , [100],
  REGION.NOURTH_AMERICA, RARITY.EXOTIC);

//South America
//7
engine.addCard('Toucan', 
  //hp, ap, deff, sp, we, life, 
  20, 5, 10, 64, 1, 18, 
  [PASSIVE.HEAL_BUFF ] , [150],
  REGION.SOUTH_AMERICA, RARITY.COMMON);

//8
engine.addCard('Piranha', 
  //hp, ap, deff, sp, we, life, 
  30, 100, 30, 17, 1, 22, 
  [PASSIVE.ATTACK_BUFF ] , [120],
  REGION.SOUTH_AMERICA, RARITY.COMMON);

//Europe
//9
engine.addCard('Reindeer', 
  //hp, ap, deff, sp, we, life, 
  200, 10, 100, 82, 300, 15, 
  [PASSIVE.SPEED_DEBUFF ] , [80],
  REGION.EUROPE, RARITY.COMMON);

//10
engine.addCard('Grass Snake', 
  //hp, ap, deff, sp, we, life, 
  50, 100, 50, 3, 1, 24, 
  [PASSIVE.POISON ] , [120],
  REGION.EUROPE, RARITY.COMMON);

//11
engine.addCard('Gray Wolf', 
  //hp, ap, deff, sp, we, life, 
  250, 100, 150, 75, 32, 12, 
  [PASSIVE.LIFESPAN_DEBUFF ] , [100],
  REGION.EUROPE, RARITY.COMMON); 

//Africa
//12
engine.addCard('Cheetah', 
  //hp, ap, deff, sp, we, life, 
  250, 150, 80, 112, 48, 11, 
  [PASSIVE.SPEED_BUFF ] , [120],
  REGION.AFRICA, RARITY.RARE); 

//13
engine.addCard('Spotted Hyena', 
  //hp, ap, deff, sp, we, life, 
  350, 250, 120, 60, 77, 24, 
  [PASSIVE.DEFENSE_DEBUFF ] , [60],
  REGION.AFRICA, RARITY.RARE);

//14
engine.addCard('Hippopotamus', 
  //hp, ap, deff, sp, we, life, 
  2500, 100, 100, 45, 2500, 45, 
  [PASSIVE.ATTACK_BUFF ] , [60],
  REGION.AFRICA, RARITY.RARE); 

//15
engine.addCard('Black Rhinoceros', 
  //hp, ap, deff, sp, we, life, 
  1000, 200, 400, 42, 1100, 47, 
  [PASSIVE.ATTACK_BUFF ] , [100],
  REGION.AFRICA, RARITY.EXOTIC);

//16
engine.addCard('Black Mamba', 
  //hp, ap, deff, sp, we, life, 
  10, 40, 10, 5, 2, 11, 
  [PASSIVE.POISON ] , [120],
  REGION.AFRICA, RARITY.RARE);

//Asia
//17
engine.addCard('Giant Panda', 
  //hp, ap, deff, sp, we, life, 
  300, 10, 300, 32, 180, 32, 
  [PASSIVE.HEAL_BUFF ] , [120],
  REGION.ASIA, RARITY.EXOTIC); 

//18
engine.addCard('Asian Elephant', 
  //hp, ap, deff, sp, we, life, 
  4000, 300, 500, 43, 4000, 67, 
  [PASSIVE.DEFENSE_BUFF ] , [200],
  REGION.ASIA, RARITY.EXOTIC); //exotic olmali?

//19
engine.addCard('King Cobra', 
  //hp, ap, deff, sp, we, life, 
  60, 70, 50, 7, 5, 18, 
  [PASSIVE.POISON ] , [90],
  REGION.ASIA, RARITY.RARE); 

//Australia
//20
engine.addCard('Tasmanian Devil', 
  //hp, ap, deff, sp, we, life, 
  120, 90, 80, 24, 7, 7, 
  [PASSIVE.ATTACK_BUFF ] , [80],
  REGION.AUSTRALIA, RARITY.EXOTIC); //exotic olmali?

//21
engine.addCard('Kangaroo', 
  //hp, ap, deff, sp, we, life, 
  200, 40, 100, 55, 65, 7, 
  [PASSIVE.HEAL_BUFF ] , [80],
  REGION.AUSTRALIA, RARITY.COMMON); 

//22
engine.addCard('Koala', 
  //hp, ap, deff, sp, we, life, 
  20, 10, 10, 2, 8, 18, 
  [PASSIVE.HEAL_BUFF ] , [180],
  REGION.AUSTRALIA, RARITY.EXOTIC); 

//Antartica

//23
engine.addCard('Elephant Seal', 
  //hp, ap, deff, sp, we, life, 
  1500, 20, 200, 19, 1800, 19, 
  [PASSIVE.LIFESPAN_DEBUFF ] , [200],
  REGION.ANTARCTICA, RARITY.COMMON); 


//OCEAN
//24
engine.addCard('Killer Whale', 
  //hp, ap, deff, sp, we, life, 
  3000, 200, 100, 44, 7500, 56, 
  [PASSIVE.LIFESPAN_BUFF ] , [400],
  REGION.OCEAN, RARITY.EXOTIC); //okyanus olmali, exotic?
//25
engine.addCard('Great White Shark', 
  //hp, ap, deff, sp, we, life, 
  1000, 300, 100, 24, 1650, 38, 
  [PASSIVE.DEFENSE_DEBUFF ] , [100],
  REGION.OCEAN, RARITY.RARE); //okyanus olmali?


//console.log(engine.cards);
//engine.printCards();

var result = engine.StartGame({
  card1: 15,
  card2: 4,
  card3: 5,
  card4: 20,
  card5: 5,
  card6: 6,
  card7: 7,
  card8: 8
},
{
  card1: 1,
  card2: 2,
  card3: 3,
  card4: 4,
  card5: 15,
  card6: 16,
  card7: 17,
  card8: 18
}
);
console.log(result);