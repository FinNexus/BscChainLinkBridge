
let fraxTestOracle = artifacts.require("fraxTestOracle");
let FraxAggregatorV3 = artifacts.require("FraxAggregatorV3");
let FNXOracle = artifacts.require("FNXOracle");
let collateral0 = "0x0000000000000000000000000000000000000000";
module.exports = async function(deployer, network,accounts) {
    await deployer.deploy(fraxTestOracle);
    await deployer.deploy(FraxAggregatorV3,fraxTestOracle.address);
    await deployer.deploy(FNXOracle);
    let oracleInstance = await FNXOracle.deployed();
    await oracleInstance.setAssetsAggregator("0x853d955acef822db058eb8505911ed77f175b99e",
        FraxAggregatorV3.address,18);
    let fraxPrice = await oracleInstance.getPrice("0x853d955acef822db058eb8505911ed77f175b99e");
    console.log("frax Price :", fraxPrice.toString(10));
//    await deployer.deploy(FNXOracle);
//    let oracleInstance = await FNXOracle.deployed();
//    await oracleInstance.addOperator("0xE732e883D03E230B7a5C2891C10222fe0a1fB2CB");
//    await oracleInstance.setPrice("0x1b95d8e5a5ea04908591c1b98a936b424705a959",5e7);
//    let btcPrice = await oracleInstance.getUnderlyingPrice(1);
//    console.log("btc Price :", btcPrice.toString(10));
//    btcPrice = await oracleInstance.getUnderlyingPrice(2);
//    console.log("ETH Price :", btcPrice.toString(10));
//    btcPrice = await oracleInstance.getPrice(collateral0);
//    console.log("ETH Price :", btcPrice.toString(10));
//    btcPrice = await oracleInstance.getPrice("0x4738635C82BED8F474D9A078F4E5797fa5d5f460");
//    console.log("ETH Price :", btcPrice.toString(10));
};
