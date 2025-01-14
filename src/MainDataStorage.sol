//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UsersLib} from "./lib/Users.sol";
import {Roles} from "./admins/Roles.sol";

/**
* @author AVZ.Tech
* @notice Stores te most important DATA
*/
contract MainDataStorage {

    Roles public roles;

    constructor(address _roles) {
        roles = Roles(_roles);
    }

    /**
    * @notice only contracts of the protocol can call this functions
    */
    modifier onlyProtocol(){
        bool isProtocol = roles.isProtocolContract(msg.sender);
        require(isProtocol, "Only Protocol Contracts can call this functions");
        _;
    }

    /**
    * @notice only Admins of the protocol can call this functions
    */
    modifier onlyAdmins() {
        require(roles.isAdmin(msg.sender), "Only Admins can call this functions");
        _;
    }

    /**
    * @notice only contracts or admins of the protocol can call this functions
    */
    modifier onlyProtocolOrAdmin(){
        bool isProtocol = roles.isProtocolContract(msg.sender);
        bool isAdmin = roles.isAdmin(msg.sender);
        require(isAdmin || isProtocol, "Only Admins or Protocol can call this functions");
        _;
    }

    error UserAccountExist(address contractAddress, address user);

    event UserCreated(address indexed user, address indexed contractAddress);

    mapping(address => UsersLib.User) internal clients;

   /**
    * @notice Creates and associates a new user with their contract and data.
    * @dev This function is restricted to Protocol addresses through the 
    *      `onlyProtocol` modifier. It checks if the user already exists 
    *      and initializes their data using the `UsersLib.User` structure.
    * @param _newUser The address of the new user to register.
    * @param _newContract The address of the contract created by the user.
    * @param _contractType Specifies the type of contract: 
    *      1 for walletContracts and 2 for onlyExecutionContracts.
    */
    function createUser(
            address _newUser,
            address _newContract,
            uint8 _contractType
        ) external onlyProtocolOrAdmin {
            address _contract = clients[_newUser].contractAddress;
            bool isRegistered = 
                _contract == address(0) ? false : true;
            if(isRegistered) 
                revert UserAccountExist(_contract, _newUser);
            UsersLib.User memory _newClient = UsersLib.User(
                _newContract, 
                _contractType
            );
            clients[_newUser] = _newClient;
            emit UserCreated(_newUser, _newContract);
    }

}