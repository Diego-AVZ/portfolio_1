//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "../Lib/Params.sol";

// SDK => import {IYourContract} from "";

contract CustomizedFunctions {

    function functionRouter(bytes4 _funcSelector, ParamManagerLib.DeFiParam[] memory _params) external payable{
        bytes4 f = _funcSelector;
        ParamManagerLib.DeFiParam[] memory p = _params;
        /**
        Write:
            if(f == 0xYourFunctionSelector){  // Get function 
                callYourFunction(withParams);
                like this: 
                    callYourFunction( p [ paramPosition ].paramType );
                    so callYourFunction( p[0].w, p[1].x ); 
                        // w for addresses. *check Documentation for more params
                        // x for uints.     *check Documentation for more params
            } else if(f == nextFunctionSelector) {
                callNextFunction
            }
        */
        if(f == 0xee5b3814){
            function1(p[0].w, p[1].w, p[2].x, p[3].x);
        } else if(f == 0x88bd413e){
            function2(p[0].x, uint24(p[1].x), int24(p[2].y), int24(p[3].y), p[4].x, p[5].x);
        } else {
            revert("Invalid function selector");
        }
    }

    /**
    * To call this function
    * function1(p[0].w, p[1].w, p[2].x, p[3].x);
    */
    function function1(
            address tokenIn,
            address tokenOut,
            uint256 amountIn,
            uint256 amountOutMin
        ) public {
        /*executor.swap();*/
    }

    function function2(
            uint256 pair,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint256 amount0,
            uint256 amount1
        ) public {
        /*executor.addLiquidity01();*/
    }

    function getFunctionSelector() public pure returns(bytes4){
        return this.function2.selector;
    }

}