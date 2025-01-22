//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockUniswapPoolState} from "../mock/MockUniswapPoolState.sol";
import {MockUniswapFactory} from "../mock/MockUniswapFactory.sol";
import {UsersLib} from "../../src/lib/Users.sol";
import {PoolSearcher} from "../../src/lib/UniswapPoolSearch.sol";

contract Test_PoolSearcher is Test{

    MockUniswapPoolState public poolA;
    MockUniswapPoolState public poolB;
    MockUniswapPoolState public poolC;
    MockUniswapFactory public factory;

    address public constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public constant AAVE = 0xD6DF932A45C0f255f85145f286eA0b292B21C90B;

    function setUp() public {
        poolA = new MockUniswapPoolState(50000000, 100, 1234567890);
        poolB = new MockUniswapPoolState(150000000, 500, 3456789098);
        poolC = new MockUniswapPoolState(90000000, 3000, 50002034567);
        factory = new MockUniswapFactory(address(poolA), address(poolB), address(poolC));
    }

    function test_searchPool() public view {
        address bestPool = PoolSearcher.searchPool(WETH, AAVE, address(factory));
        assertEq(bestPool, address(poolB));
    }

    function test_searchPoolWithOrderTokens() public view {
        address bestPool = PoolSearcher.searchPool(AAVE, WETH, address(factory)); // changing the order of the tokens 
        assertEq(bestPool, address(poolB));                                       //   library should order them
    }

}