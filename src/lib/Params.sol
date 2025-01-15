//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library ParamManagerLib {

    struct DeFiParam {
        uint8 _type;
        bytes v;
        address w;
        uint256 x;
        int256 y;
        bool z;
        bytes[] aV;
        address[] aW;
        uint256[] aX;
    }

}