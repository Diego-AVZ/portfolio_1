//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "./lib/Params.sol";
import {ISwapRouter} from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IUniswapV3PoolState} from "../lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol";
import {PoolSearcher} from "./lib/UniswapPoolSearch.sol";
import {UniswapUtils} from "./lib/UniswapUtils.sol";

contract Functions {

    address public constant SWAP_ROUTER = address(0x123); // INITIALIZE with UNISWAP Router address
    address public constant UNI_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    function functionRouter(bytes4 _funcSelector, ParamManagerLib.DeFiParam[] memory _params) external payable returns(bool){
        bytes4 f = _funcSelector;
        ParamManagerLib.DeFiParam[] memory p = _params;
        bool success;
        if(f == 0xee5b3814){
            success = swap(p[0].w, p[1].w, p[2].x, p[3].x);
        } else if(f == 0x88bd413e){
            addLiquidity01(p[0].x, uint24(p[1].x), int24(p[2].y), int24(p[3].y), p[4].x, p[5].x);
        }else if(f == 0x88bd413e){
            success = uniswapSwap(p[0].w, p[1].w, p[2].w, p[3].x, p[4].x);
        } else {
            revert("Invalid function selector");
        }
    }

    function swap(
            address tokenIn,
            address tokenOut,
            uint256 amountIn,
            uint256 amountOutMin
        ) internal returns(bool){
        /*executor.swap();*/
    }

    function addLiquidity01(
            uint256 pair,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint256 amount0,
            uint256 amount1
        ) internal {
        /*executor.addLiquidity01();*/
    }

    function uniswapSwap(
            address tokenIn,
            address tokenOut,
            address recipient,
            uint256 amountIn,
            uint256 slippage
        ) internal returns(bool){
            address pool = PoolSearcher.searchPool(tokenIn, tokenOut, UNI_V3_FACTORY);
            uint8 fee = UniswapUtils.getPoolFee(pool);
            address[] memory path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
            uint256 amountOutMin = UniswapUtils.getAmountOutMin(pool, slippage, amountIn, path);
            uint160 sqrtPriceLimitX96 = UniswapUtils.getLimitSqrtPrice(pool, slippage, path);
            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
                {
                    tokenIn : tokenIn,
                    tokenOut : tokenOut,
                    fee : fee,
                    recipient : recipient,
                    deadline : block.timestamp + 350,
                    amountIn : amountIn,
                    amountOutMinimum : amountOutMin,
                    sqrtPriceLimitX96 : sqrtPriceLimitX96
                }
            );
            uint256 amountOut = ISwapRouter(SWAP_ROUTER).exactInputSingle(params);
            return(amountOut >= amountOutMin);
    }

}