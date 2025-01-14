//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Roles} from "./admins/Roles.sol";
import {ParamManagerLib} from "./Lib/Params.sol";
import {IFunctions} from "./interfaces/IFunctions.sol";

/**
* @author AVZ.Tech
* @notice User interacts with this contract trough `main.sol`
*         Type1 means that user can use this contract as wallet to hold Funds
*/
contract walletContract {

    address[] public owners; 

    IFunctions public functions;

    constructor(address _owner, address _secondOwner) {
        owners.push(_owner);
        if(_secondOwner != address(0)) owners.push(_secondOwner); 
        functions = IFunctions(address(0x123));
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
        uint256[] memory paramsTypes = abi.decode(_actionData[4:36], (uint256[]));
        ParamManagerLib.DeFiParam[] memory params = new ParamManagerLib.DeFiParam[](paramsTypes.length);
        uint256 offset = 36; // (FuncSelector == 4) +(ParamsTypesArray == 32) == 36
        for(uint256 i = 0; i < paramsTypes.length; i++){
            ParamManagerLib.DeFiParam memory param;
            if(paramsTypes[i] == 0){
                param._type = 0;
                param.w = abi.decode(_actionData[offset:offset+32], (address));
                offset += 32;
            } else if(paramsTypes[i] == 1){
                param._type = 1;
                param.x = abi.decode(_actionData[offset:offset+32], (uint256));
                offset += 32;
            } else if(paramsTypes[i] == 2){
                param._type = 2;
                param.y = abi.decode(_actionData[offset:offset+32], (int256));
                offset += 32;
            } else if(paramsTypes[i] == 3){
                param._type = 3;
                param.z = abi.decode(_actionData[offset:offset+32], (bool));
                offset += 32;
            } else {
                revert InvalidParams("action");
            }
            params[i] = param;
        }
        functions.functionRouter(functionSelector, params);
    }


}