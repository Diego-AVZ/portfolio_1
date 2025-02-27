//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Factory} from "../../src/core/Factory.sol";
import {MockDataStorage} from "../mock/MockDataStorage.sol";
import {MockRoles} from "../mock/MockRoles.sol";


contract test_Factory is Test {

    Factory public factory;
    MockDataStorage public data;

    function setUp() public {
        address roles = address(new MockRoles()); 
        data = new MockDataStorage(roles);
        factory = new Factory(address(data));
    }

    function test_deployNewContract() public {
        factory.deployNewContract(address(0x456));
        address userContract = data.getUserData(address(0x456)).contractAddress;
        assert(userContract != address(0));
    }

}