var LoveLib = artifacts.require("./Love.sol");

module.exports = function(deployer) {
  deployer.deploy(LoveLib);
};
