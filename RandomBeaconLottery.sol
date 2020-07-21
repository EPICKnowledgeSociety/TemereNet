pragma solidity ^0.5.2;

import "github.com/starkware-libs/veedo/blob/master/contracts/BeaconContract.sol";

    
contract Beacon{
    function getLatestRandomness()external view returns(uint256,bytes32){}
    
}
   contract Lottery{ 
    
    address payable public owner;
    address payable[] public players;
    enum status {open,closed,alreadyplayed}
    status currentstatus;
    address public BeaconContractAddress=0x79474439753C7c70011C3b00e06e559378bAD040;
    
    //contract constructor
    constructor() public{
    
        owner = msg.sender;
        currentstatus=status.open;
     
    }
     
    
    modifier onlyowner(){
        require(msg.sender==owner);
        _;
    }
    
    
    modifier onlyWhileopen {
        require(currentstatus==status.open,"currently closed");
        _;
    }
    
    modifier costs(uint _amount){
        
        require(msg.value>=2 ether,"not enough ether provided");
        _;
    }
    
    

    function setBeaconContractAddress(address _address) public onlyowner {
        BeaconContractAddress=_address;
    }
    
        
    function() external payable onlyWhileopen costs(2 ether) {
        
        currentstatus=status.alreadyplayed;
        players.push(msg.sender); //add the address of the account that sends ether to players array
                                  
    }
    
    
    function get_balance() public view onlyowner returns(uint){
        return address(this).balance; //return contract balance()
    }
    
    
    //returns randomNumber
    function generateRandomNumber() public view returns(bytes32){
        uint blockNumber;
        bytes32 randomNumber;
        Beacon beacon=Beacon(BeaconContractAddress);
        (blockNumber,randomNumber)=beacon.getLatestRandomness();
        return randomNumber;
       
    }
    
    function selectWinner() public onlyowner{
        uint r=uint256(generateRandomNumber());
        address payable winner;
        uint index=r%players.length;
        winner=players[index];
        winner.transfer(address(this).balance);
        
        players=new address payable[](0);
        
    }
    
    
}
