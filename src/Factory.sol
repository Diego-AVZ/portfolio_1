//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WalletContract} from "./UserContractType1.sol";
import {MainDataStorage} from "./MainDataStorage.sol";

contract Factory {

    MainDataStorage public data;

    constructor(address _data){
        data = MainDataStorage(_data);
    }
    
    function deployNewContract(address _newUser) public {
        WalletContract _newContract = new WalletContract(_newUser, address(0));
        data.createUser(_newUser, address(_newContract), 1);
    }
    
}