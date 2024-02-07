// Raffle
// Stoped @ 14:14
//Enter the lottery
// PICK WInner
// Winner picked X minutes

// Chailink oracle

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "node_modules/@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "node_modules/@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "node_modules/@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
error Raffle_NotEnoughtETH();
error NoRecentWin();
error Raffle_NotOpen();
error Raffle_UpkeepNotNeeded( uint256 currentBalance, uint256 numPlayers, uint256 raffleState);

contract Raffle is VRFConsumerBaseV2,KeeperCompatibleInterface{
    // VAR
    uint256 private immutable i_entrancefee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subId;
    uint16 private constant REQINFO = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant Num_words = 1;
    // Lot Var
     address private s_recentWinner;
     enum RaffleState{
        OPEN,
        CALCULATING
     }
     RaffleState private s_raffleState;
     uint256 private s_lastTimeStamp;
     uint256 private immutable i_interval;
    // Events 
    event RaffleEnster(address indexed player);
    event RequestedRaffleWin(uint256 requstId);
    event WeHaveAWinner(address indexed winner);
    // Contsructor
    constructor(address vrfCoordinatorV2 ,uint256 entrancefee, bytes32 gasLane, uint64 subId,
    uint32 callbackGasLimit, uint256 interval) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entrancefee = entrancefee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subId = subId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        i_interval = interval;
    }

    function enterRaffle() public payable{
        if(msg.value < i_entrancefee){
            revert Raffle_NotEnoughtETH();
        }
        if(s_raffleState != RaffleState.OPEN){
            revert Raffle_NotOpen();
        }
        s_players.push(payable(msg.sender));
        //events
        emit RaffleEnster(msg.sender);
    }
    
    function fulfillRandomWords(uint256 /* requestID*/, uint256[] memory randomWords) internal override{
        uint256 indexofWinner = randomWords[0] % s_players.length;
        address payable recentWin = s_players[indexofWinner];
        s_recentWinner = recentWin;
        s_raffleState  = RaffleState.OPEN;
        s_players = new address payable[](0); 
        s_lastTimeStamp = block.timestamp;
        (bool success,) = recentWin.call{value: address(this).balance}("");
        //require seccess
        if(!success){
            revert NoRecentWin();
        }
        emit WeHaveAWinner(recentWin);
    } 
    function checkUpkeep(bytes memory /*checkData*/)public override returns (bool upkeepNeeded, bytes memory /*performData*/ ){
        bool isOpen = (RaffleState.OPEN == s_raffleState);
        bool timePassed = ((block.timestamp - s_lastTimeStamp)>i_interval);
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasBalance && hasPlayers);

    }
    function performUpkeep(bytes calldata /*performData*/) external override{
        (bool upkeepNeeded, ) = checkUpkeep("");
        if(!upkeepNeeded){
            revert Raffle_UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestID =  i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subId,
            REQINFO,
            i_callbackGasLimit,
            Num_words);
        emit RequestedRaffleWin(requestID);
    }

    

    function getRecentWin() public view returns(address){
        return s_recentWinner;
    }
    function getFee() public view returns(uint256){
        return i_entrancefee;
    }
    function getPlayer(uint256 index) public view returns(address){
        return s_players[index];
    }
    function getRaffleState() public view returns (RaffleState){
        return s_raffleState;
    }
    function getNumWords() public pure returns(uint256){
        return Num_words;
    }
    function getNumPlayers() public view returns(uint256){
        return s_players.length;
    } 
    function getInterval() public view returns(uint256){
        return i_interval;
    }
}
