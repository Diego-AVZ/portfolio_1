// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UsersLib} from "../../src/lib/Users.sol";
import {MockRoles} from "../mock/MockRoles.sol";
import {MainDataStorage} from "../../src/core/MainDataStorage.sol";

contract MainDataStorageTest is Test {

    MainDataStorage public data;
    MockRoles public roles;

    address public constant ADMIN1 = 0x132adfe17b67f91573f3853DB9682D9E937e3C91;
    address public constant PROTOCOL_CONTRACT = address(0x00005555);

    function setUp() public {
        roles = new MockRoles();
        data = new MainDataStorage(address(roles), address(0x01), address(0x02));
    }

    function test_createUser() public {
        data.createUser(address(0x123), address(0x123abc), 0);
        address _contract = data.getUserData(address(0x123)).contractAddress;
        assertEq(_contract, address(0x123abc));
    }

    function test_tryCreateExistingUser() public {
        test_createUser();
        vm.expectRevert(
            abi.encodeWithSelector(
                MainDataStorage.UserAccountExist.selector,
                address(0x123abc),
                address(0x123)
            )
        );
        data.createUser(address(0x123), address(0x123abc), 0);
    }

    // vm.prank(sender);
    // vm.startPrank(sender); // para multiples llamadas

}