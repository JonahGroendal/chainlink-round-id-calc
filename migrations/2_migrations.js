const Migrations = artifacts.require("Migrations");
const ChainlinkRoundIdCalc = artifacts.require("ChainlinkRoundIdCalc");
const TestContract = artifacts.require("TestContract");
//const TestChainlinkRoundIdCalc = artifacts.require("TestChainlinkRoundIdCalc");


module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(ChainlinkRoundIdCalc);
    await deployer.link(ChainlinkRoundIdCalc, TestContract);
    await deployer.deploy(TestContract);
    //await deployer.link(ChainlinkRoundIdCalc, TestChainlinkRoundIdCalc);
    //await deployer.deploy(TestChainlinkRoundIdCalc);
}   