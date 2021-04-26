var Balances = artifacts.require('Token');
module.exports = function(deployer){
    deployer.deploy(Balances);
};