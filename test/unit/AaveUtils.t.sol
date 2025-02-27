//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockIPoolAddressProider} from "../mock/MockIPoolAddressesProvider.sol";
import {MockIPriceOracle} from "../mock/MockIPriceOracle.sol";
import {MockIPool} from "../mock/MockIPool.sol";
import {AaveUtils} from "../../src/core/AaveUtils.sol";

contract Test_AaveUtils is Test {

    MockIPoolAddressProider public addressProv;
    MockIPriceOracle public oracle;
    MockIPool public pool;
    AaveUtils public aaveUtils;

    address public token1 = address(0x0987);
    address public token2 = address(0x0765);

    function setUp() public{
        pool = new MockIPool();
        oracle = new MockIPriceOracle();
        addressProv = new MockIPoolAddressProider(address(oracle));
        aaveUtils = new AaveUtils(address(pool), address(addressProv));
    }

    function test_calculateMaxBorrowPower() public view {
        AaveUtils.AaveToken[] memory tokenArray = new AaveUtils.AaveToken[](2);
        tokenArray[0] = AaveUtils.AaveToken(token1,100);
        tokenArray[1] = AaveUtils.AaveToken(token2,300);
        uint256 maxBorrow = aaveUtils.calculateMaxBorrowPower(tokenArray);
        assertEq(maxBorrow, 200000);
    }

}