//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "../Lib/Params.sol";

interface IFunctions {

    //for swap() 0x00 => [0,0,1,1] 
    function functionRouter(bytes4 _funcSelector, ParamManagerLib.DeFiParam[] memory _params) external;

}