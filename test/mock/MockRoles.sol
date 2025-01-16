// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockRoles {

    constructor(){
        isAdmin[0x132adfe17b67f91573f3853DB9682D9E937e3C91] = true;
    }

    function isProtocolContract(address _addr) public pure returns(bool){
        return true;
    }

    mapping(address => bool) public isAdmin;

}