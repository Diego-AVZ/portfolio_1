//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "../lib/Params.sol";

interface IFunctions {

    function functionRouter(bytes4 _funcSelector, ParamManagerLib.DeFiParam[] memory _params) external payable returns(bool);
    function approveRequired(bytes4 _funcSelector) external pure returns(bool isRequired, uint8 token, uint8 amount);
}