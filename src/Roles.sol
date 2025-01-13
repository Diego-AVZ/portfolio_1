//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Roles {

    address public constant ADMIN1 = 0x132adfe17b67f91573f3853DB9682D9E937e3C91;

    mapping(address => bool) public isAdmin;
    mapping(address => uint8) internal AdminPenalities;

    address[] public protocolAddresses;

    function getProtocolAddresses() public view returns(address[] memory){
        return protocolAddresses;
    }
}