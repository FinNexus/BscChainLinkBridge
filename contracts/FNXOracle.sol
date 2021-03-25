pragma solidity ^0.6.11;
import "./modules/Operator.sol";
import "./interfaces/AggregatorV3Interface.sol";
import "./interfaces/IERC20.sol";

contract FNXOracle is Operator {
    mapping(uint256 => AggregatorV3Interface) private assetsMap;
    mapping(uint256 => uint256) private decimalsMap;
    mapping(uint256 => uint256) private priceMap;
    uint256 internal decimals = 1;

    /**
     * Network: Ropsten
     * Aggregator: LTC/USD
     * Address: 0x727B59d0989d6D1961138122BC9F94f534E82B32
     */
    constructor() public {
        //mainnet
        assetsMap[1] = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
        assetsMap[2] = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        assetsMap[3] = AggregatorV3Interface(0x24551a8Fb2A7211A25a17B1481f043A8a8adC7f2);
        assetsMap[4] = AggregatorV3Interface(0xDC3EA94CD0AC27d9A86C180091e7f78C683d3699);
        assetsMap[5] = AggregatorV3Interface(0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c);
        assetsMap[0] = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        assetsMap[uint256(0xeF9Cd7882c067686691B6fF49e650b43AFBBCC6B)] = AggregatorV3Interface(0x80070f7151BdDbbB1361937ad4839317af99AE6c);
        priceMap[uint256(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)] = 1e20;
        decimalsMap[0] = 18;
        decimalsMap[1] = 18;
        decimalsMap[2] = 18;
        decimalsMap[3] = 18;
        decimalsMap[4] = 18;
        decimalsMap[5] = 18;
        decimalsMap[uint256(0xeF9Cd7882c067686691B6fF49e650b43AFBBCC6B)] = 18;
        decimalsMap[uint256(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)] = 6;
        /*
        //rinkeby
        assetsMap[1] = AggregatorV3Interface(0xECe365B379E1dD183B20fc5f022230C044d51404);
        assetsMap[2] = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        assetsMap[3] = AggregatorV3Interface(0xd8bD0a1cB028a31AA859A21A3758685a95dE4623);
        assetsMap[4] = AggregatorV3Interface(0xE96C4407597CD507002dF88ff6E0008AB41266Ee);
        assetsMap[5] = AggregatorV3Interface(0xd8bD0a1cB028a31AA859A21A3758685a95dE4623);
        assetsMap[0] = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        assetsMap[uint256(0xaf30F6A6B09728a4e793ED6d9D0A7CcBa192c229)] = AggregatorV3Interface(0xcf74110A02b1D391B27cE37364ABc3b279B1d9D1);
        priceMap[uint256(0xD12BC93Ac5eA2b4Ba99e0ffEd053a53B6d18C7a3)] = 1e20;
        decimalsMap[0] = 18;
        decimalsMap[1] = 18;
        decimalsMap[2] = 18;
        decimalsMap[3] = 18;
        decimalsMap[4] = 18;
        decimalsMap[5] = 18;
        decimalsMap[uint256(0xaf30F6A6B09728a4e793ED6d9D0A7CcBa192c229)] = 18;
        decimalsMap[uint256(0xD12BC93Ac5eA2b4Ba99e0ffEd053a53B6d18C7a3)] = 6;
        */


    }
    function setDecimals(uint256 newDecimals) public onlyOwner{
        decimals = newDecimals;
    }
    function getAssetAndUnderlyingPrice(address asset,uint256 underlying) public view returns (uint256,uint256) {
        return (getUnderlyingPrice(uint256(asset)),getUnderlyingPrice(underlying));
    }
    function setPrices(uint256[]memory assets,uint256[]memory prices) public onlyOwner {
        require(assets.length == prices.length, "input arrays' length are not equal");
        uint256 len = assets.length;
        for (uint i=0;i<len;i++){
            priceMap[i] = prices[i];
        }
    }
    function getPrices(uint256[]memory assets) public view returns (uint256[]memory) {
        uint256 len = assets.length;
        uint256[] memory prices = new uint256[](len);
        for (uint i=0;i<len;i++){
            prices[i] = getUnderlyingPrice(assets[i]);
        }
        return prices;
    }
        /**
  * @notice retrieves price of an asset
  * @dev function to get price for an asset
  * @param asset Asset for which to get the price
  * @return uint mantissa of asset price (scaled by 1e8) or zero if unset or contract paused
  */
    function getPrice(address asset) public view returns (uint256) {
        return getUnderlyingPrice(uint256(asset));
    }
    function getUnderlyingPrice(uint256 underlying) public view returns (uint256) {
        if (underlying == 3){
            return getMKRPrice();
        }
        AggregatorV3Interface assetsPrice = assetsMap[underlying];
        if (address(assetsPrice) != address(0)){
            (, int price,,,) = assetsPrice.latestRoundData();
            uint256 tokenDecimals = decimalsMap[underlying];
            if (tokenDecimals < 18){
                return uint256(price)/decimals*(10**(18-tokenDecimals));  
            }else if (tokenDecimals > 18){
                return uint256(price)/decimals/(10**(18-tokenDecimals)); 
            }else{
                return uint256(price)/decimals;
            }
        }else {
            return priceMap[underlying];
        }
    }
    function getMKRPrice() internal view returns (uint256) {
        AggregatorV3Interface assetsPrice = assetsMap[3];
        AggregatorV3Interface ethPrice = assetsMap[0];
        if (address(assetsPrice) != address(0) && address(ethPrice) != address(0)){
            (, int price,,,) = assetsPrice.latestRoundData();
            (, int ethPrice,,,) = ethPrice.latestRoundData();
            uint256 tokenDecimals = decimalsMap[3];
            uint256 mkrPrice = uint256(price*ethPrice)/decimals/1e18;
            if (tokenDecimals < 18){
                return mkrPrice/decimals*(10**(18-tokenDecimals));  
            }else if (tokenDecimals > 18){
                return mkrPrice/decimals/(10**(18-tokenDecimals)); 
            }else{
                return mkrPrice/decimals;
            }
        }else {
            return priceMap[3];
        }
    }
    /**
      * @notice set price of an asset
      * @dev function to set price for an asset
      * @param asset Asset for which to set the price
      * @param price the Asset's price
      */    
    function setPrice(address asset,uint256 price) public onlyOperatorIndex(0) {
        priceMap[uint256(asset)] = price;

    }
    /**
      * @notice set price of an underlying
      * @dev function to set price for an underlying
      * @param underlying underlying for which to set the price
      * @param price the underlying's price
      */  
    function setUnderlyingPrice(uint256 underlying,uint256 price) public onlyOperatorIndex(0) {
        require(underlying>0 , "underlying cannot be zero");
        priceMap[underlying] = price;
    }
        /**
      * @notice set price of an asset
      * @dev function to set price for an asset
      * @param asset Asset for which to set the price
      * @param aggergator the Asset's aggergator
      */    
    function setAssetsAggregator(address asset,address aggergator,uint256 _decimals) public onlyOwner {
        assetsMap[uint256(asset)] = AggregatorV3Interface(aggergator);
        decimalsMap[uint256(asset)] = _decimals;
    }
    /**
      * @notice set price of an underlying
      * @dev function to set price for an underlying
      * @param underlying underlying for which to set the price
      * @param aggergator the underlying's aggergator
      */  
    function setUnderlyingAggregator(uint256 underlying,address aggergator,uint256 _decimals) public onlyOwner {
        require(underlying>0 , "underlying cannot be zero");
        assetsMap[underlying] = AggregatorV3Interface(aggergator);
        decimalsMap[underlying] = _decimals;
    }
    function getAssetsAggregator(address asset) public view returns (address,uint256) {
        return (address(assetsMap[uint256(asset)]),decimalsMap[uint256(asset)]);
    }
    function getUnderlyingAggregator(uint256 underlying) public view returns (address,uint256) {
        return (address(assetsMap[underlying]),decimalsMap[underlying]);
    }
}