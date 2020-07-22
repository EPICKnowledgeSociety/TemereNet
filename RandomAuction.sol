pragma solidity ^0.5.2;

import "github.com/starkware-libs/veedo/blob/master/contracts/BeaconContract.sol";

contract Beacon{
    function getLatestRandomness()external view returns(uint256,bytes32){}
    
}

contract RandomAuction {
    
    address public BeaconContractAddress=0x79474439753C7c70011C3b00e06e559378bAD040;


    // Initialization Remembering bids from each address.
    mapping (address => uint) bids;
    
    // Also remembering the max_bid and the max_bidder 
    //to easily determine the winner.
    
    uint max_bid = 0;
    address max_bidder;
    
    // Seller is always the creator of the contract.
    address creator = msg.sender;
    
    // When the auction is closed: 100 blocks after creation.

    
    function setBeaconContractAddress(address _address) public  {
        BeaconContractAddress=_address;
    }
    
    function generateRandomNumber() public view returns(bytes32){
        uint blockNumber;
        bytes32 randomNumber;
        Beacon beacon=Beacon(BeaconContractAddress);
        (blockNumber,randomNumber)=beacon.getLatestRandomness();
        return randomNumber;
       
    }
    
    // Interface bid().
    function bid() public payable returns (bool bid_made) {
        // When the auction is over, go to the payout procedure.
        if ((bytes32(block.number))> generateRandomNumber()) {
            return withdraw();
        }
        // Otherwise, record the bid.
        bids[msg.sender] += msg.value;
        // Sometimes, the current bid is the maximal bid so far.
        if (bids[msg.sender] > max_bid) {
            max_bid = bids[msg.sender];
            max_bidder = msg.sender;
        }
        return true;
    }
    
    // Interface withdraw().  Pays back to those who didn't win the
    // auction.  The winner's bid goes to the seller.
    function withdraw() public payable returns (bool done) {
        // Anything sent along the withdraw request shall be sent back.
        uint payout = msg.value;
        
        // If the auction is still going, withdrawal is not possible.
        // That would require finding the second winner when the current winner cancels
        // its bid.
        if (bytes32(block.number) < generateRandomNumber()) {
            msg.sender.transfer(payout);
            return false;
        }

        // The seller gets the winner's bid.
        if (msg.sender == creator) {
            payout += max_bid;
            // But the next time, the seller will not get it.
            max_bid = 0;
        }
        // The losing bidders get their own bids,
        if (msg.sender != max_bidder) {
            payout += bids[msg.sender];
            // but not next time.
            bids[msg.sender] = 0;
        }
        // The caller gets its payout.
        msg.sender.transfer(payout);
        return true;
    }
    
    // The winner can be found by looking at the value of max_bidder variable.
    // An invalid call gets a payback (provided sufficient gas).
    
    function () payable external {
        msg.sender.transfer(msg.value);
    }
}
