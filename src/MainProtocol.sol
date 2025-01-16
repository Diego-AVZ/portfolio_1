//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MainDataStorage} from "./MainDataStorage.sol";
import {Factory} from "./Factory.sol";
import {WalletContract} from "./WalletContract.sol";

contract Main {

    MainDataStorage public data;
    Factory public factory;

    constructor(address _dataStorage, address _factory){
        data = MainDataStorage(_dataStorage);
        factory = Factory(_factory);
    }

    function defiAction(bytes[] calldata _action) public payable{
        address payable _contractAddress = payable(data.getUserData(msg.sender).contractAddress);
        WalletContract(_contractAddress).defiAction{ value: msg.value }(_action, msg.sender);
    }
}