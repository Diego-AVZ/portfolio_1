//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockUniswapPoolState} from "../mock/MockUniswapPoolState.sol";
import {UniswapUtils} from "../../src/lib/UniswapUtils.sol";

contract Test_UniswapUtils is Test {

    MockUniswapPoolState public pool;

    address public constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public constant AAVE = 0xD6DF932A45C0f255f85145f286eA0b292B21C90B;
    uint160 public constant SQRT = 242061440113340438903998146713;
    uint256 public constant AMOUNT_IN = 100000;
    uint256 public constant SLIPPAGE = 50;

    function setUp() public {
        pool = new MockUniswapPoolState(1000000000, 3000, SQRT);
    }

    function test_getLimitSqrtPriceFromToken1ToToken0() public view {
        address[] memory path = new address[](2);
        path[0] = AAVE;
        path[1] = WETH;
        uint160 limitSqrt = UniswapUtils.getLimitSqrtPrice(address(pool), SLIPPAGE, path);
        uint160 x = SQRT + (SQRT * uint160(SLIPPAGE)/1000);
        assertEq(limitSqrt, x);
    }

    function test_getLimitSqrtPriceFromToken0ToToken1() public view {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = AAVE;
        uint160 limitSqrt = UniswapUtils.getLimitSqrtPrice(address(pool), SLIPPAGE, path);
        uint160 x = SQRT - (SQRT * uint160(SLIPPAGE) / 1000);
        assertEq(limitSqrt, x);
    }

    function test_getAmountOutMinFromToken1ToToken0() public view {
        address[] memory path = new address[](2);
        path[0] = AAVE;
        path[1] = WETH;
        uint256 amountOutMin = UniswapUtils.getAmountOutMin(address(pool), SLIPPAGE, AMOUNT_IN, path);
        uint256 x = AMOUNT_IN * (1 << 96)/ (uint256(SQRT) * uint256(SQRT) >> 96);
        uint256 y = x * (1000 - SLIPPAGE)/1000;
        assertEq(amountOutMin, y);
    }

}