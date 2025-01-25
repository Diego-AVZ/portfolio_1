//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; 

import {UniswapV3Factory} from "../../lib/v3-core/contracts/UniswapV3Factory.sol";
import {IUniswapV3PoolState} from "../../lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol";
import {UniswapUtils} from "./UniswapUtils.sol";

library PoolSearcher {
    
    /**
    * @notice Searches for the most suitable pool to swap between two tokens (`tokenA` and `tokenB`) 
    *      across a specified factory contract. The function iterates over predefined fee tiers
    *      to locate pools and selects the best one based on predefined criteria.
    * @param tokenA Address of the first token in the pair.
    * @param tokenB Address of the second token in the pair.
    * @param _factory Address of the factory contract responsible for creating and managing pools.
    * @return poolToSwap The address of the selected pool for swapping, or `address(0)` if no valid pool is found.
    */
    function searchPool(address tokenA, address tokenB, address _factory) external view returns(address poolToSwap) {
        uint24[] memory fees = new uint24[](4);
        fees[0] = 100;
        fees[1] = 500;
        fees[2] = 3000;
        fees[3] = 10000;
        (address token0, address token1) = orderTokens(tokenA,tokenB);
        address[] memory pools = new address[](4);
        uint8 poolsCount = 0;
        for(uint8 i = 0; i < 4; i++){
            address pool = checkPools(token0, token1, _factory, fees[i]);
            pools[i] = pool;
            poolsCount = pool != address(0) 
                ? poolsCount + 1 
                : poolsCount;
        }
        poolToSwap =  searchBestPool(pools, poolsCount);
        return poolToSwap;
    }

    function checkPools(address token0, address token1, address _factory, uint24 _fee) public view returns(address pool) {
        pool = UniswapV3Factory(_factory).getPool(token0, token1, _fee);
        return pool;
    }

    function orderTokens(address tokenA, address tokenB) public pure returns(address token0, address token1){
        address[] memory tokens = UniswapUtils.orderTokensInPool(tokenA, tokenB);
        return(tokens[0], tokens[1]);
    }

    function searchBestPool(address[] memory _pools, uint8 _poolsCount) public view returns(address) {
        uint128[] memory liquidityInPools = new uint128[](_poolsCount);
        for(uint8 i = 0; i < 4; i++){
            if(_pools[i] != address(0)){
                uint128 liquidity = IUniswapV3PoolState(_pools[i]).liquidity();
                liquidityInPools[i] = liquidity;
            }
        }
        uint8 bestLiquidity = getLargerLiquidity(liquidityInPools);
        return(_pools[bestLiquidity]);
    }

    function getLargerLiquidity(uint128[] memory li) public pure returns(uint8){
        uint256 len = li.length;
        uint8 largerLiq = 0;
        for(uint8 i = 1; i < len; i++){
            if(li[i] > li[largerLiq]){
                largerLiq = i;
            }
        }
        return largerLiq;
    }
 
}