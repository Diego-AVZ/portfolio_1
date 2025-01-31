//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MainDataStorage} from "./MainDataStorage.sol";
import {Factory} from "./Factory.sol";
import {IWalletContract} from "../interfaces/IWalletContract.sol";

contract Main {

    MainDataStorage public data;
    Factory public factory;

    constructor(address _dataStorage, address _factory){
        data = MainDataStorage(_dataStorage);
        factory = Factory(_factory);
    }

    function defiAction(bytes[] calldata _action) public {
        address _contractAddress = data.getUserData(msg.sender).contractAddress;
        IWalletContract(_contractAddress).defiAction(_action, msg.sender);
    }
    
}