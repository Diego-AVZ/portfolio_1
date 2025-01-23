//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WalletContract} from "./WalletContract.sol";
import {MainDataStorage} from "./MainDataStorage.sol";
import {Roles} from "./admins/Roles.sol";

contract Factory {

    MainDataStorage public data;
    Roles public roles;

    constructor(address _data){
        data = MainDataStorage(_data);
        (,address _roles,) = data.getContracts();
        roles = Roles(_roles);
    }
    
    function deployNewContract(address _newUser) public {
        (address functions, , address wEth) = data.getContracts();
        WalletContract _newContract = new WalletContract(_newUser, address(0), functions, address(roles), wEth);
        data.createUser(_newUser, address(_newContract), 1);
    }
    
}