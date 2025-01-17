//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockRoles} from "../mock/MockRoles.sol";
import {TestToken} from "../mock/MockERC20.sol";
import {MockFunctions} from "../mock/MockFunctions.sol";
import {WalletContract} from "../../src/WalletContract.sol";
import {IERC20} from "../../lib/openzeppelin/contracts/interfaces/IERC20.sol";

contract test_WalletContract is Test {

    WalletContract public walletContract;
    TestToken public testToken;
    MockFunctions public mockFunctions;

    address public constant USER1 = address(0x12345);

    function setUp() public {
        mockFunctions = new MockFunctions();
        walletContract = new WalletContract(USER1,address(0),address(mockFunctions));
        testToken = new TestToken(USER1);
    }

    function test_receive() public {
        //vm.deal(USER1, 10 ether);
        //assertEq(USER1.balance, 10 ether);
        (bool success,) = payable(address(walletContract)).call{value: 1 ether}("");
        assert(success);
    }

    function test_depositFunds_ether() public {
        //vm.deal(USER1, 10 ether);
        //assertEq(USER1.balance, 10 ether);
        walletContract.depositFunds{value : 3 ether}(address(0), 3 ether);
        uint256 balance = walletContract.getContractEtherBalance();
        assertEq(balance, 3 ether);
    }

    function test_depositFunds_erc20() public{
        vm.startPrank(USER1);
        testToken.approve(address(walletContract), 3000);
        walletContract.depositFunds{value : 0 ether}(address(testToken), 3000);
        uint256 balance = testToken.balanceOf(address(walletContract));
        assert(balance == 3000);
    }

    function test_withdrawFunds_erc20() public {
        test_depositFunds_erc20();
        uint256 userBalanceBefore = testToken.balanceOf(USER1);
        walletContract.withdrawFunds(address(testToken), 3000, USER1, USER1);
        uint256 contractBalance = testToken.balanceOf(address(walletContract));
        assertEq(contractBalance, 0);
        uint256 userBalanceAfter = testToken.balanceOf(USER1);
        assertEq(userBalanceAfter, userBalanceBefore + 3000);
    }

    function test_defiActions() public {
        bytes memory selector = hex"ee5b3814";
        bytes memory encoded1 = hex"0000000000000000000000000000000000000000000000000000000000000020" 
                                hex"0000000000000000000000000000000000000000000000000000000000000002"  
                                hex"0000000000000000000000000000000000000000000000000000000000000000"  
                                hex"0000000000000000000000000000000000000000000000000000000000000001";
        bytes memory encoded2 = hex"00000000000000000000000043d218197e8c5fbc0527769821503660861c7045"  
                                hex"000000000000000000000000000000000000000000000000000000000000270f";
        bytes[] memory actionData = new bytes[](3);
        actionData[0] = selector;
        actionData[1] = encoded1;
        actionData[2] = encoded2;
        
        bool success = walletContract.defiAction(actionData, USER1);
        assert(success);
    }

    
}