//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WalletContract} from "./WalletContract.sol";
import {MainDataStorage} from "./MainDataStorage.sol";

contract Factory {

    MainDataStorage public data;

    constructor(address _data){
        data = MainDataStorage(_data);
    }
    
    // Check method to get functions contract (and others)
    function deployNewContract(address _newUser, address functions) public {
        WalletContract _newContract = new WalletContract(_newUser, address(0), functions);
        data.createUser(_newUser, address(_newContract), 1);
    }
    
}