//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Functions} from "../../src/core/Functions.sol";
import {MockDataStorage} from "../mock/MockDataStorage.sol";
import {MockRoles} from "../mock/MockRoles.sol";
import {ParamManagerLib} from "../../src/lib/Params.sol";

contract test_Functions is Test {

    Functions public functions;
    MockDataStorage public data;

    function setUp() public {
        address roles = address(new MockRoles()); 
        data = new MockDataStorage(roles);
        functions = new Functions(address(data));
        data.createUser(msg.sender, address(0x987), 1);
    }

    function test_functionRouter() public {
        ParamManagerLib.DeFiParam[] memory params = new ParamManagerLib.DeFiParam[](4);
        ParamManagerLib.DeFiParam memory params1 = ParamManagerLib.DeFiParam(
            0,"0x123",
            address(0x456),
            0,0,false
        );
        ParamManagerLib.DeFiParam memory params2 = ParamManagerLib.DeFiParam(
            0,"0x123",
            address(0x123),
            0,0,false
        );
        ParamManagerLib.DeFiParam memory params3 = ParamManagerLib.DeFiParam(
            0,"0x123",
            address(0),
            1000,0,false
        );
        ParamManagerLib.DeFiParam memory params4 = ParamManagerLib.DeFiParam(
            0,"0x123",
            address(0),
            2000,0,false
        );
        params[0] = params1;
        params[1] = params2;
        params[2] = params3;
        params[3] = params4;
        bool success = functions.functionRouter(
            0xee5b3814,
            params
        );
        assert(success);
    }
}