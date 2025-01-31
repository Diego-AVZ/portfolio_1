//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockRoles} from "../mock/MockRoles.sol";
import {TestToken} from "../mock/MockERC20.sol";
import {TestWEth} from "../mock/MockWEth.sol";
import {MockFunctions} from "../mock/MockFunctions.sol";
import {WalletContract} from "../../src/core/WalletContract.sol";
import {IERC20} from "../../lib/openzeppelin/contracts/interfaces/IERC20.sol";
import {MockERC20} from "../mock/MockERC20.sol";

contract test_WalletContract is Test {

    MockERC20 public usdc;
    WalletContract public walletContract;
    TestToken public testToken;
    TestWEth public testWEth;
    MockFunctions public mockFunctions;
    MockRoles public mockRoles;

    address public constant USER1 = address(0x12345);

    function setUp() public {
        usdc = new MockERC20(USER1);
        address mainnetUsdc =  0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
        vm.etch(mainnetUsdc, address(usdc).code);
        mockFunctions = new MockFunctions();
        mockRoles = new MockRoles();
        testWEth = new TestWEth();
        walletContract = new WalletContract(USER1,address(0), address(mockFunctions), address(mockRoles), address(testWEth));
        testToken = new TestToken(USER1);
    }

    function test_app() public  {
        IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913).approve(address(mockFunctions), 1000);
        uint allow = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913).allowance(address(this), address(mockFunctions));
        assertEq(allow, 1000);
    }

    function test_receive() public {
        (bool success,) = payable(address(walletContract)).call{value: 1 ether}("");
        assert(success);
    }

    function test_depositFunds_ether() public {
        //vm.deal(USER1, 10 ether);
        //assertEq(USER1.balance, 10 ether);
        walletContract.depositFunds{value : 3 ether}(USER1, address(0), 3 ether);
        uint256 balance = testWEth.balanceOf(address(walletContract));
        assertEq(balance, 3*1e18);
    }

    function test_depositFunds_erc20() public{
        vm.startPrank(USER1);
        testToken.approve(address(walletContract), 3000);
        walletContract.depositFunds{value : 0 ether}(USER1, address(testToken), 3000);
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

    function test_defiActions2() public { // UniswapSwap()
        bytes memory selector = hex"469e635e";
        bytes memory encoded1 = hex"0000000000000000000000000000000000000000000000000000000000000020"
                                hex"0000000000000000000000000000000000000000000000000000000000000005"
                                hex"0000000000000000000000000000000000000000000000000000000000000000"
                                hex"0000000000000000000000000000000000000000000000000000000000000000"
                                hex"0000000000000000000000000000000000000000000000000000000000000000"
                                hex"0000000000000000000000000000000000000000000000000000000000000001"
                                hex"0000000000000000000000000000000000000000000000000000000000000001";
        bytes memory encoded2 = hex"000000000000000000000000833589fcd6edb6e08f4c7c32d4f71b54bda02913"
                                hex"0000000000000000000000004200000000000000000000000000000000000006"
                                hex"000000000000000000000000132adfe17b67f91573f3853db9682d9e937e3c91"
                                hex"00000000000000000000000000000000000000000000000000000000000186a0"
                                hex"000000000000000000000000000000000000000000000000000000000000000a";

        bytes[] memory actionData = new bytes[](3);
        actionData[0] = selector;
        actionData[1] = encoded1;
        actionData[2] = encoded2;
        
        bool success = walletContract.defiAction(actionData, USER1);
        console.log("LOG LOG LOG => ", success);
        assert(success);
    }

    
}

// forge test --match-path test/unit/WalletContract.t.sol