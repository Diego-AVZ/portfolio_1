//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Roles {

    modifier onlyAdmins(){
        require(isAdmin[msg.sender], "Access denied: caller is not an admin");
        require(AdminPenalities[msg.sender] == 0, "Access denied: admin is penalized");
        _;
    }

    address public constant ADMIN1 = 0x132adfe17b67f91573f3853DB9682D9E937e3C91;

    constructor(){
        isAdmin[ADMIN1] = true;
    }

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

    function addAdmin(address newAdmin) public {
        require(msg.sender == ADMIN1);
        isAdmin[newAdmin] = true;
    }

    function isProtocolContract(address _addr) public view returns(bool){
        return protocolContracts[_addr].isProtocolContract;
    }
}