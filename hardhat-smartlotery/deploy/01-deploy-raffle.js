const { ethers } = require("hardhat");
const { developmentChains, networkConfig } = require("../../helper-hardhat-config")
const { verify } = require("../../helper-hardhat-config.js")
const { network } = require("hardhat")
//const { VERIFICATION_BLOCK_CONFIRMATIONS } = require("../../helper-hardhat-config.js")

const VRF_SUB_FUND_AMOUNT = ethers.utils.parseEther("1")

module.exports = async function ({getNamedAccounts, deployments}) {
    const {deploy, log} = deployments
    const {deployer} = await getNamedAccounts()
    const chainId = network.config.chainId
    let vrfCoordinatorV2Address ,subscriptionId
    if(developmentChains.includes(network.name)){
        //await deployments.fixture(["VRFCoordinatorV2Mock"]);
        //const myContract = await deployments.get("VRFCoordinatorV2Mock");
        /*const vrfCoordinatorV2Mock = await ethers.getContractAt(
            myContract.abi,
            myContract.address
            );
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock*/
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const transactionResponse = await vrfCoordinatorV2Mock.createSubscription()
        const transactionReceipt = await transactionResponse.wait(1)
        subscriptionId = transactionReceipt.events[0].args.subId 
        /*get an error we bypass that
         As we can by pass it because we know it is the first subscript so we can do this*/
        //subscriptionId = 1
        //Fund the Sub
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, VRF_SUB_FUND_AMOUNT)
    }else{
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"]
        subscriptionId = networkConfig[chainId]["subscriptionId"]
    }
    const entranceFee = networkConfig[chainId]["entranceFee"]
    const gasLane = networkConfig[chainId]["gasLane"]
    const callbackGasLimit = networkConfig[chainId]["callbackGasLimit"]
    const interval = networkConfig[chainId]["interval"]

    const args = [vrfCoordinatorV2Address,entranceFee,gasLane, subscriptionId,callbackGasLimit,interval]
    /*const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS
*/
    log("----------------------------------------------------")


    const raffle = await deploy("Raffle", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1 ,
    })

    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){
        log("Verifying....")
        await verify(raffle.address, args)
    }
    log("-------------------------------------------------------")

}
module.exports.tags = ["all", "raffle"]