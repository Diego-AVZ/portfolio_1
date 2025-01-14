//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Roles {

    modifier onlyAdmins(){
        require(isAdmin[msg.sender], "You Are not Admin, Only Admins can call this functions");
        _;
    }

    address public constant ADMIN1 = 0x132adfe17b67f91573f3853DB9682D9E937e3C91;

    struct Contract {
        bool isProtocolContract;
        string name;
        string description;
    }

    mapping(address => bool) public isAdmin;
    mapping(address => uint8) private AdminPenalities;
    mapping(address => Contract) public protocolContracts;

    function setProtocolContract(
            address _newContractAddress, 
            string calldata _name, 
            string calldata _description
        ) public onlyAdmins {
            Contract memory _newContract = Contract(
                {
                    isProtocolContract : true,
                    name : _name,
                    description : _description
                }
            );
            protocolContracts[_newContractAddress] = _newContract;
    }

    function isProtocolContract(address _addr) public view returns(bool){
        return protocolContracts[_addr].isProtocolContract;
    }
}