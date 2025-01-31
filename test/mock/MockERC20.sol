//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20("test", "TEST") {
    constructor(address _deployer){
        _mint(_deployer, 1000000);
    }
}

contract MockERC20 is ERC20("usdc", "usdc") {
    constructor(address _deployer){
        _mint(_deployer, 1000000);
    }
}