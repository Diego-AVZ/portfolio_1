//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "./lib/Params.sol";
import {ISwapRouter} from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Functions {

    ISwapRouter public swapRouter;

    function functionRouter(bytes4 _funcSelector, ParamManagerLib.DeFiParam[] memory _params) external payable returns(bool){
        bytes4 f = _funcSelector;
        ParamManagerLib.DeFiParam[] memory p = _params;
        bool success;
        if(f == 0xee5b3814){
            success = swap(p[0].w, p[1].w, p[2].x, p[3].x);
        } else if(f == 0x88bd413e){
            addLiquidity01(p[0].x, uint24(p[1].x), int24(p[2].y), int24(p[3].y), p[4].x, p[5].x);
        }else if(f == 0x88bd413e){
            uniswapSwap();
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
            uint256 deadline,
            uint256 amountIn,
            uint256 amountOutMinimum,
            uint160 sqrtPriceLimitX96
        ) internal {
            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
                {
                    tokenIn : tokenIn,
                    tokenOut : tokenOut,
                    fee : _fee,
                    recipient : recipient,
                    deadline : 10000,
                    amountIn : amountIn,
                    amountOutMinimum : amountOutMinimum,
                    sqrtPriceLimitX96 : sqrtPriceLimitX96
                }
            );
    }

}