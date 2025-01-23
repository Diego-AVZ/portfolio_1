//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../../src/Factory.sol";
import {MockDataStorage} from "../mock/MockDataStorage.sol";

contract test_Factory is Test {

    Factory public factory;
    MockDataStorage public data;

    function setUp() public {
        data = new MockDataStorage();
        factory = new Factory(address(data));
    }

    function test_deployNewContract() public {
        factory.deployNewContract(address(0x123));
        address userContract = data.getUserData(address(0x123)).contractAddress;
        assert(userContract != address(0));
    }

}