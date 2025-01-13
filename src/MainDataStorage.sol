//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UsersLib} from "./lib/Users.sol";
import {Roles} from "./Roles.sol";

/**
* @author AVZ.Tech
* @title Stores te most important DATA
*/
contract MainDataStorage {

    Roles public roles;

    constructor(address _roles) {
        roles = Roles(_roles);
    }

    address[] public protocolAddresses;

    modifier onlyProtocol(){
        bool isProtocol;
        for(uint16 i = 0; i < protocolAddresses.length; i++){
            if(msg.sender == protocolAddresses[i]){
                isProtocol = true;
                break;
            }
        }
        require(isProtocol, "Only Protocol Contracts can call this functions");
        _;
    }

    modifier onlyAdmins() {
        require(roles.isAdmin(msg.sender), "Only Admins can call this functions");
        _;
    }

    modifier onlyProtocolOrAdmin(){
        bool isProtocol;
        for(uint16 i = 0; i < protocolAddresses.length; i++){
            if(msg.sender == protocolAddresses[i]){
                isProtocol = true;
                break;
            }
        }
        require(roles.isAdmin(msg.sender) || isProtocol, "Only Admins or Protocol can call this functions");
        _;
    }

    mapping(address => UsersLib.User) internal Clients;

    function createUser(
            address _newUser,
            address _newContract,
            uint8 _contractType
        ) external onlyProtocol {
            UsersLib.User memory _newClient = UsersLib.User(_newContract, _contractType);
            Clients[_newUser] = _newClient;
    }

    function setProtocolAddreses() public onlyAdmins {
        delete protocolAddresses;
        address[] memory addresses = roles.getProtocolAddresses();
        for(uint16 i = 0; i < addresses.length; i++){
            protocolAddresses.push(addresses[i]);
        }
    }

}