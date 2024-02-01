// Raffle

//Enter the lottery
// PICK WInner
// Winner picked X minutes

// Chailink oracle

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "node_modules/@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
error Raffle_NotEnoughtETH();

contract Raffle is VRFConsumerBaseV2{
    uint256 private immutable i_entrancefee;
    address payable[] private s_players;
    event RaffleEnster(address indexed player);
    constructor(address vrfCoordinatorV2 ,uint256 entrancefee) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entrancefee = entrancefee;
    }

    function enterRaffle() public payable{
        if(msg.value < i_entrancefee){
            revert Raffle_NotEnoughtETH();
        }
        s_players.push(payable(msg.sender));
        //events
        emit RaffleEnster(msg.sender);
    }
    function reqpickRandomNumb()external{

    }
    function fulfillRandomWords(uint256 reqID, uint256[] memory randomWords) internal override{

    }
    function getFee() public view returns(uint256){
        return i_entrancefee;
    }
    function getPlayer(uint256 index) public view returns(address){
        return s_players[index];
    }
}