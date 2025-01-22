//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "../../src/lib/Params.sol";

contract MockFunctions {

    function functionRouter(bytes4 _funcSelector, ParamManagerLib.DeFiParam[] memory _params) external payable returns(bool){
        bytes4 f = _funcSelector;
        ParamManagerLib.DeFiParam[] memory p = _params;
        if(f == 0xee5b3814){
           return swap(p[0].w, p[1].x);
        } else {
            return false;
        }
    }

    function swap(
            address tokenIn,
            uint256 amountIn
        ) internal pure returns(bool){
            if(
                tokenIn == address(0x43D218197E8c5FBC0527769821503660861c7045) &&
                amountIn == 9999
            ){
                return true;
            } else {
                return false;
            }
    }

    function approveRequired(bytes4 _funcSelector) external pure returns(bool isRequired, uint8 token, uint8 amount){
        bytes4 f = _funcSelector;
        if(f == 0xee5b3814){
            //
        } else if(f == 0x88bd413e){
            //
        }else if(f == 0x469e635e){
            //uniswapSwap();
            isRequired = true;
            token = 0;
            amount = 3;
        } else {
            revert("Invalid function selector");
        }
        return(isRequired, token, amount);
    }

}