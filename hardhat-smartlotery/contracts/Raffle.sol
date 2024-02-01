// Raffle

//Enter the lottery
// PICK WInner
// Winner picked X minutes

// Chailink oracle

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

error Raffle_NotEnoughtETH();

contract Raffle{
    uint256 private immutable i_entrancefee;
    address payable[] private s_players;
    constructor(uint256 entrancefee){
        i_entrancefee = entrancefee;
    }
    function enterRaffle() public payable{
        if(msg.value < i_entrancefee){
            revert Raffle_NotEnoughtETH();
        }
        s_players.push(payable(msg.sender));
        //events
        
    }
    function getFee() public view returns(uint256){
        return i_entrancefee;
    }
    function getPlayer(uint256 index) public view returns(address){
        return s_players[index];
    }
}