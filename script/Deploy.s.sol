//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; 

import {Script, console} from "forge-std/Script.sol";
import {Functions} from "../src/core/Functions.sol";
import {MainDataStorage} from "../src/core/MainDataStorage.sol";
import {Roles} from "../src/admins/Roles.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast(); 
        //MainDataStorage data = new MainDataStorage();
        //Functions functions = new Functions(data);
        //console.log("functions deployed at:", address(functions));
        //verify("Functions", address(functions));
        vm.stopBroadcast();
    }

/*
    function verify(string memory name, address _contract) public {
        string[] memory verifyCmd = new string[](5);
        verifyCmd[0] = "forge";
        verifyCmd[1] = "verify-contract";
        verifyCmd[2] = vm.toString(_contract);
        verifyCmd[3] = name;
        verifyCmd[4] = vm.envString("API_KEY");
        vm.ffi(verifyCmd);

    }
    */
}

// forge verify-contract 0xE52ecBECE7c6B07a0aDd4B0DDC0eef0B2083F459 src/Functions.sol:Functions
/*
forge verify-contract 0x4a9d5A2315b638a86C8727FacEa161A99e13C3c9 src/Functions.sol:Functions --etherscan-api-key "CKCSUNW8CXHQ1FZVGAN2XR7HEUSGFCIBK5" --libraries "PoolSearcher:0x25c75b0da51dc44f59d2037ee2b9d88016148161,UniswapUtils:0xc575ad8fb1642a3f2a76a9b52ff39af77b7b3c87"
forge verify-contract 0x4a9d5A2315b638a86C8727FacEa161A99e13C3c9 src/Functions.sol:Functions --libraries "PoolSearcher:0x25c75b0da51dc44f59d2037ee2b9d88016148161,UniswapUtils:0xc575ad8fb1642a3f2a76a9b52ff39af77b7b3c87"

*/

/**
forge script script/Deploy.s.sol:Deploy --rpc-url https://base-mainnet.g.alchemy.com/v2/M-sZlZo1MNsl7Kps9FiRwNKk4NDkjNKT --private-key e5dce96ee19184dbcb1faee8c2381eb98684ff3ba6cf5202ccb3e5a440e832 --broadcast
*/
//https://arbitrum-sepolia-rpc.publicnode.com
//https://eth-sepolia.api.onfinality.io/public
//https://arb-sepolia.g.alchemy.com/v2/M-sZlZo1MNsl7Kps9FiRwNKk4NDkjNKT
// https://base.llamarpc.com
// apiKey CKCSUNW8CXHQ1FZVGAN2XR7HEUSGFCIBK5
// forge verify-contract 0xE52ecBECE7c6B07a0aDd4B0DDC0eef0B2083F459 Functions --etherscan-api-key CKCSUNW8CXHQ1FZVGAN2XR7HEUSGFCIBK5
