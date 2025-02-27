//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DataTypes} from '../../lib/aave/contracts/protocol/libraries/types/DataTypes.sol';

contract MockIPool {

    function getReserveData(address asset) external view returns (DataTypes.ReserveData memory){
        DataTypes.ReserveData memory data = DataTypes.ReserveData({
            configuration: DataTypes.ReserveConfigurationMap({ data: 5000 }), // LTV = 60%
            liquidityIndex: 1.02e27,              
            currentLiquidityRate: 0.01e27,       
            variableBorrowIndex: 1.03e27,        
            currentVariableBorrowRate: 0.03e27,   
            currentStableBorrowRate: 0.04e27,     
            lastUpdateTimestamp: uint40(block.timestamp), 
            id: 1,                                
            aTokenAddress: address(0x1111),       
            stableDebtTokenAddress: address(0x2222),
            variableDebtTokenAddress: address(0x3333),
            interestRateStrategyAddress: address(0x4444),
            accruedToTreasury: 1000,            
            unbacked: 0,                        
            isolationModeTotalDebt: 0           
        });
        return data;
    }


    

}