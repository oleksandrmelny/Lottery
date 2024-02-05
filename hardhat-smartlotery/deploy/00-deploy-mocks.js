const { ethers } = require("")
const { developmentChains} = require("../../helper-hardhat-config")
const BASEFEE = ethers.parseEther("0.25") // 0.25 is the primium. It cost 0.25 LINK per REQ
const GAS_PRICE_LINK = 1e9 //link per gas. calculated value based on the gas of the chain


module.exports = async function({getNamedAccounts, deployments}){
    const {deploy,log} = deployments
    const {deployer} = await getNamedAccounts()
    const args = [BASEFEE,GAS_PRICE_LINK]    
    if(developmentChains.includes(network.name)){
        log("Local network detected! Deploying mocks")
        // deploy a mock vrfcoordinator...
        await deploy("VRFCoordinatorV2Mock",{
        from: deployer,
        log: true,
        args: args,
    })
    log("Mocks Deployed")
    log("----------------------------------------------------")
    }
}
module.exports.tags = ["all", "mocks"]