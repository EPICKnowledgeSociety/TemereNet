pragma solidity ^0.5.2;

import "github.com/starkware-libs/veedo/blob/master/contracts/BeaconContract.sol";

contract Beacon{
    function getLatestRandomness()external view returns(uint256,bytes32){}
    
}


contract WeatherOracle {
    
  address public oracleAddress;
  
  address public BeaconContractAddress=0x79474439753C7c70011C3b00e06e559378bAD040;

  constructor (address _oracleAddress) public {
    oracleAddress = _oracleAddress;
  }
  
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

  event WeatherUpdate (
    string weatherDescription,
    string temperature,
    string humidity,
    string visibility,
    string windSpeed,
    string windDirection,
    string windGust
  );

  function updateWeather (
    string memory weatherDescription,
    string memory temperature,
    string memory humidity,
    string memory visibility,
    string memory windSpeed,
    string memory windDirection,
    string memory windGust
  )
  public
  {
    require(msg.sender == oracleAddress);

   if ((bytes32(block.number))> generateRandomNumber()) {

    emit WeatherUpdate (
      weatherDescription,
      temperature,
      humidity,
      visibility,
      windSpeed,
      windDirection,
      windGust
    );
   }
  }
}
