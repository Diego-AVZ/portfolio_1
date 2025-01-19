//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; 

import {UniswapV3Factory} from "../../lib/v3-core/contracts/UniswapV3Factory.sol";
import {IUniswapV3PoolState} from "../../lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol";

library PoolSearcher {

    uint24[4] public fees = [100, 500, 3000, 10000];
 
    function searchPool(address tokenA, address tokenB, address _factory) internal view returns(address poolToSwap) {
        (address token0, address token1) = orderTokens(tokenA,tokenB);
        address[] memory pools = new address[](4);
        uint8 poolsCount = 0;
        for(uint8 i = 0; i < 4; i++){
            address pool = checkPools(token0, token1, _factory, fee);
            pools.push(pool);
            poolsCount = pool != address(0) ? poolsCount++ : poolsCount;
        }
        poolToSwap = poolsCount > 1 ? searchBestPool(pools, poolsCount) : getAvailablePool(pools);
        return poolToSwap;
    }

    function checkPools(address token0, address token1, address _factory, uint24 _fee) internal view returns(address pool) {
        pool = UniswapV3Factory(_factory).getPool(token0, token1, fee);
        return pool;
    }

    function orderTokens(address tokenA, address tokenB) internal view returns(address token0, address token1){
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return(token0, token1);
    }

    function searchBestPool(address[] memory _pools, uint8 _poolsCount) internal view returns(address) {
        uint128[] memory liquidityInPools = new uint128[](_poolsCount);
        for(uint8 = 0; i < 4; i++){
            if(pools[i] != address(0)){
                uint128 liquidity = IUniswapV3PoolState(pools[i]).liquidity();
                liquidityInPools.push(liquidity);
            }
        }
        uint8 bestLiquidity = getLargerLiquidity(liquidityInPools);
        return(_pools[bestLiquidity]);
    }

    function getLargerLiquidity(uint128[] memory li) internal view returns(uint8){
        uint256 len = li.length;
        uint8 largerLiq;
        for(uint8 i = 0; i < len; i++){
            if(i < len - 1){
                largerLiq = li[i] > li[i+1] ? li[i] : li[i+1];
            } else {
                largerLiq = li[i] > largerLiq ? li[i] : largerLiq;
            }
        } 
        return largerLiq;
    }
 
}