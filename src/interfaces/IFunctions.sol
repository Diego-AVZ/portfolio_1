//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "../lib/Params.sol";

interface IFunctions {

    function functionRouter(bytes4, ParamManagerLib.DeFiParam[] memory) external payable returns(bool);
    function approveRequired(bytes4) external pure returns(bool, uint8[] memory, uint8[] memory, uint8);

}