// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {UsersLib} from "../../src/lib/Users.sol";
import {Roles} from "../../src/admins/Roles.sol";
import {MainDataStorage} from "../../src/MainDataStorage.sol";

contract MainDataStorageTest is Test {

    MainDataStorage public data;
    Roles public roles;

    address public constant ADMIN1 = 0x132adfe17b67f91573f3853DB9682D9E937e3C91;
    address public constant PROTOCOL_CONTRACT = address(0x00005555);

    function setUp() public {
        roles = new Roles();
        data = new MainDataStorage(address(roles), address(0x01), address(0x02));
        vm.prank(ADMIN1);
        roles.setProtocolContract(PROTOCOL_CONTRACT, "testContract", "sets a contract address for testing");
    }

    function test_setProtocolContract() public {
        vm.prank(ADMIN1);
        roles.setProtocolContract(address(0x789), "testContract", "sets a contract address for testing");
        bool isProtocol = roles.isProtocolContract(address(0x789));
        assertEq(isProtocol, true);
    }

    function test_createUser() public {
        vm.prank(PROTOCOL_CONTRACT);
        data.createUser(address(0x123), address(0x123abc), 0);
        address _contract = data.getUserData(address(0x123)).contractAddress;
        assertEq(_contract, address(0x123abc));
    }

    function test_tryCreateExistingUser() public {
        test_createUser();
        vm.prank(PROTOCOL_CONTRACT);
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