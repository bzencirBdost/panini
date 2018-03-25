var Migrations = artifacts.require("./Migrations.sol");

//libs
var SafeMath = artifacts.require("./contracts/library/safe_math.sol");
//generals
var Owned = artifacts.require("./contracts/general/owned.sol");
var Mortal = artifacts.require("./contracts/general/owned/mortal.sol");
var FixedSupplyToken = artifacts.require("./contracts/general/fixed_supply_token.sol");
//panini's
var PaniniToken = artifacts.require("./contracts/panini/panini_token.sol");
//panini
var Panini = artifacts.require("./contracts/panini.sol");



module.exports = function(deployer) {
	//deployer.deploy(Migrations);
	//libs
	//deployer.deploy(SafeMath);
	//generals
	//deployer.deploy(Owned);
	//deployer.deploy(Mortal);
	//deployer.deploy(FixedSupplyToken);
	//panini's
	//deployer.deploy(PaniniToken);

	//panini
	deployer.deploy(Panini);

};
