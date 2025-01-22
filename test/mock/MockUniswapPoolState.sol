//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; 

contract MockUniswapPoolState {

    uint128 public liq;
    uint160 public sqrt;
    uint24 public poolFee; 

    constructor(uint128 x, uint24 y, uint160 z){
        liq = x;
        poolFee = y;
        sqrt = z;
    }

    function liquidity() external view returns (uint128){
        return liq;
    }

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        ){
            sqrtPriceX96 = sqrt;
            tick = 42315;
            observationIndex = 0;
            observationCardinality = 0;
            observationCardinalityNext = 0;
            feeProtocol = 0;
            unlocked = true;
            return(
                sqrtPriceX96,
                tick,
                observationIndex,
                observationCardinality,
                observationCardinalityNext,
                feeProtocol,
                unlocked
            );
    }

    function fee() external view returns(uint24){
        return poolFee;
    }

}