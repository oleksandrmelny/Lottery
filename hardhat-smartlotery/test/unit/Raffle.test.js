const { network, getNamedAccounts, deployments, ethers } = require("hardhat")
const {developmentChains, networkConfig} = require("../../../helper-hardhat-config")
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace")
const { assert } = require("chai")

!developmentChains.includes(network.name) 
? describe.skip 
: describe("Raffle Unit Tests", async function(){
    let raffle, vrfCoordinatorV2Mock
    const chainId = network.config.chainId

    beforEach(async function(){
        const {deployer} = await getNamedAccounts()
        await deployments.fixture(["all"])
        raffle = await ethers.getContract("Raffle", deployer)
        vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
    })
    describe("constructor", async function(){
        it("Inatialize the raffle correctly", async function(){
            const raffleState = await raffle.getRaffleState()
            const interval = await raffle.getInterval()
            assert.equal(raffleState.toString(),"0")
            assert.equal(interval.toString(), networkConfig(chainId)["interval"])

        })
    })
})