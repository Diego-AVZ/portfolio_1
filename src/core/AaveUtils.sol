//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IPool} from "../../lib/aave/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "../../lib/aave/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "../../lib/aave/contracts/interfaces/IPriceOracle.sol";
import {DataTypes} from "../../lib/aave/contracts/protocol/libraries/types/DataTypes.sol";
import {IERC20} from "../../lib/openzeppelin/contracts/interfaces/IERC20.sol";

contract AaveUtils {

    /*
    address public constant AAVE_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
    address public constant ADDRESSES_PROV = 0xe20fCBdBfFC4Dd138cE8b2E6FBb6CB49777ad64D;
    */
    address public aavePool;
    address public addressesProv;

    constructor(address _aavePool, address _prov){
        aavePool = _aavePool;
        addressesProv = _prov;
    }

    struct AaveToken {
        address token;
        uint256 balance;
    }

    function calculateMaxBorrowPower(AaveToken[] calldata aaveTokens) public view returns(uint256 maxBorrow) {
        address oracle = IPoolAddressesProvider(addressesProv).getPriceOracle();
        for(uint8 i = 0; i < aaveTokens.length; i++){
            maxBorrow += calculateBorrowPowerByAsset(aaveTokens[i].token, aaveTokens[i].balance, oracle);
        }
        return maxBorrow;
    }

    function calculateBorrowPowerByAsset(address _asset, uint256 balance, address oracle) public view returns(uint256) {
        DataTypes.ReserveConfigurationMap memory config = IPool(aavePool).getReserveData(_asset).configuration;
        uint256 LTV = config.data & ((1 << 16) - 1);  
        uint256 price = IPriceOracle(oracle).getAssetPrice(_asset); 
        uint256 balanceValue = price * balance;
        uint256 maxBorrowThisAsset = (balanceValue * LTV) / 10000;
        return maxBorrowThisAsset;
    }

    function reviewATokens(address _aToken, AaveToken[] calldata aaveTokens) public pure returns(uint8){
        for(uint8 i = 0; i < aaveTokens.length; i++){
            if(aaveTokens[i].token == _aToken){
                return i;
            }
        }
        return 255;
    }

    function getReserveData(address _asset) external view returns(address){
        return IPool(aavePool).getReserveData(_asset).aTokenAddress;
    }

    function valueToAmount(address _asset, uint256 _value) external view returns(uint256){
        address oracle = IPoolAddressesProvider(addressesProv).getPriceOracle();
        uint256 price = IPriceOracle(oracle).getAssetPrice(_asset);
        uint256 amount = price * _value;
        return amount;
    }
}