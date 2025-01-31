//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "../../src/lib/Params.sol";

contract MockFunctions {

    function functionRouter(bytes4 _funcSelector, ParamManagerLib.DeFiParam[] memory _params) external payable returns(bool){
        bytes4 f = _funcSelector;
        ParamManagerLib.DeFiParam[] memory p = _params;
        if(f == 0xee5b3814){
           return swap(p[0].w, p[1].x);
        } else if(f == 0x469e635e){
            return uniswapSwap(p[0].w, p[1].w, msg.sender, p[3].x, p[4].x);
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

    function uniswapSwap(
            address tokenIn,
            address tokenOut,
            address sender,
            uint256 amountIn,
            uint256 slippage
        ) public pure returns(bool){
            if(
                tokenIn == 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 &&
                amountIn == 100000
            ){
                return true;
            } else {
                return false;
            }
        }

    function approveRequired(bytes4 _funcSelector) external pure returns(bool isRequired, uint8[] memory, uint8[] memory, uint8 approvals){
        bytes4 f = _funcSelector;
        uint8[] memory tokens = new uint8[](5);
        uint8[] memory amounts = new uint8[](5);
        if(f == 0xee5b3814){
            //
            isRequired = false;
        } else if(f == 0x88bd413e){
            //
        }else if(f == 0x469e635e){
            //uniswapSwap();
            isRequired = true;
            approvals = 1;
            tokens[0] = 0;
            amounts[0] = 3;
        } else {
            revert("Invalid function selector");
        }
        return(isRequired, tokens, amounts, approvals);
    }

}