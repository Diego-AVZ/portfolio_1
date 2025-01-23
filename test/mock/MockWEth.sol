//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../../lib/openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestWEth is ERC20("testwETH", "testWEth") {
    function deposit() public payable {
        _mint(msg.sender, msg.value);
    }
}