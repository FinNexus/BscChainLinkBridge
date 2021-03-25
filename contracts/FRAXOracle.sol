pragma solidity ^0.6.11;
interface FraxOracleInterface {
    function price0Average()external view returns (uint224);
}
contract FraxAggregatorV3 {
    constructor(address fraxOracle) public {
        _fraxOracle = FraxOracleInterface(fraxOracle);
    }
    FraxOracleInterface internal _fraxOracle;   
    function decimals() external view returns (uint8){
        return 18;
    }
    function description() external view returns (string memory){
        return "FRAX";
    }
    function version() external view returns (uint256){
        return 1;
    }

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        ){
        int256 fraxPrice = int256(_fraxOracle.price0Average());
        return (0,(fraxPrice*1e20)>>112,0,0,0);
    }
    function latestRoundData()
        external
        view
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        ){
        int256 fraxPrice = int256(_fraxOracle.price0Average());
        return (0,(fraxPrice*1e20)>>112,0,0,0);
    }

}