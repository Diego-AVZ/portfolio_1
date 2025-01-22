//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; 

import {IUniswapV3PoolState} from "../../lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol";

library UniswapUtils {

    function orderTokensInPool(address a, address b) public pure returns(address[] memory) {    
        address[] memory tokens = new address[](2);
        (tokens[0], tokens[1]) = a > b ? (b,a) : (a,b);
        return tokens;
    }

    function  getCurrentSqrtPrice(address _poolState) internal view returns(uint160){
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3PoolState(_poolState).slot0();
        return sqrtPriceX96;
    }

    function getLimitSqrtPrice(
            address _poolState,
            uint256 slippage, // (50 for 5%), (10 for 1%), (5 for 0.5%)
            address[] calldata path
        ) public view returns(uint160) {
            uint160 price = getCurrentSqrtPrice(_poolState);
            uint160 limitPrice = path[0] > path[1] 
                        ? price + ((price*uint160(slippage))/1000) 
                        : price - ((price*uint160(slippage))/1000);
            return limitPrice;
    }

    function getAmountOutMin(
            address _poolState,
            uint256 slippage,
            uint256 amountIn,
            address[] calldata path
        ) public view returns(uint256 amountOutMin) {
            uint160 sqrtPrice = getCurrentSqrtPrice(_poolState);
            uint256 price = (uint256(sqrtPrice) * uint256(sqrtPrice)) >> 96;      
            uint256 amountOut = path[0] > path[1] 
                ? (amountIn * (1 << 96)) / price      // token1 -> token0
                : (amountIn * price) >> 96;           // token0 -> token1
                
            amountOutMin = amountOut * (1000 - slippage) / 1000;
            return amountOutMin;
    }

    function getPoolFee(address _pool) external view returns(uint24 fee){
        (fee) = IUniswapV3PoolState(_pool).fee();
        return fee;
    }


    
}