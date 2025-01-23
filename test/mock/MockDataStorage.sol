//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UsersLib} from "../../src/lib/Users.sol";

contract MockDataStorage {

    error UserAccountExist(address contractAddress, address user);

    event UserCreated(address indexed user, address indexed contractAddress);

    mapping(address => UsersLib.User) internal clients;

    address public functions;
    address public wEth;

    function createUser(
            address _newUser,
            address _newContract,
            uint8 _contractType
        ) external {
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

    function getUserData(address account) external view returns(UsersLib.User memory){
        return(clients[account]);
    }

    function getContracts() public view returns(address, address, address){
        return(
            functions,
            address(0x123),
            wEth
        );
    }
}