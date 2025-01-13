//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Roles} from "./Roles.sol";
import {UsersLib} from "./Lib/Users.sol";
/**
* @author AVZ.Tech
* @notice User interacts with this contract trough `main.sol`
*         Type1 means that user can use this contract as wallet to hold Funds
*/
contract walletContract {

    address[] public owners; 

    constructor(address _owner, address _secondOwner) {
        owners.push(_owner);
        if(_secondOwner != address(0)) owners.push(_secondOwner); 
    }

    error InvalidParams(string functionName);

    event EtherReceived(address indexed sender, uint256 amount);

    receive() external payable{
        require(msg.value > 0, "Send more Ether");
        emit EtherReceived(msg.sender, msg.value);
    }

    function fundContract(address _token) public payable {
        if(_token != address(0) && msg.value == 0) revert InvalidParams("fundContract");
    }

    function action(bytes calldata _actionData) public {
        bytes4 functionSelector = abi.decode(_actionData[:4], (bytes4));
        uint256[] memory paramsTypes = abi.decode(_actionData[4:], (uint256[]));
        UsersLib.DeFiParam memory param;
        UsersLib.DeFiParam[] memory params = new UsersLib.DeFiParam[](paramsTypes.length);
        uint256 offset = 36; // (FuncSelector == 4) +(ParamsTypesArray == 32) == 36
        for(uint256 i = 0; i < paramsTypes.length; i++){
            if(paramsTypes[i] == 0){
                param.w = abi.decode(_actionData[offset:offset+32], (address));
                offset += 32;
            } else if(paramsTypes[i] == 1){
                param.x = abi.decode(_actionData[offset:offset+32], (uint256));
                offset += 32;
            } else if(paramsTypes[i] == 2){
                param.y = abi.decode(_actionData[offset:offset+32], (int256));
                offset += 32;
            } else if(paramsTypes[i] == 3){
                param.z = abi.decode(_actionData[offset:offset+32], (bool));
                offset += 32;
            } else {
                revert InvalidParams("action");
            }
        }
    }


}