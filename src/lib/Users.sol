//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library UsersLib {
    
    /**
    *
    */
    struct User {
        address contractAddress;
        uint8 contractType;
    }

    struct DeFiParam {
        address w;
        uint256 x;
        int256 y;
        bool z;

    }

}