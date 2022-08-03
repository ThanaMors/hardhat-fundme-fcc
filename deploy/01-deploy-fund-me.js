const { network } = require("hardhat")
const { networkConfig, developmentChain } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
require("dotenv").config()

//anonymous async function that takes the hardhat runtime environment
module.exports = async ({ getNamedAccounts, deployments }) => {
    //const {getNamedAccounts, deployments } = hre; same as passing hre into the parenthesis
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //let ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"] //gonna pull based on what network we deploy, if rinkeby then its gonna pull 4
    let ethUsdPriceFeedAddress
    if (developmentChain.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator") //gets deployments
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    //when going for localhost we want to use a mock
    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, //put priceFeed address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChain.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }

    log("----------------------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
