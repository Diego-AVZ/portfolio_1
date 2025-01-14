//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Roles} from "./admins/Roles.sol";
import {ParamManagerLib} from "./Lib/Params.sol";
import {IFunctions} from "./interfaces/IFunctions.sol";
import {IERC20} from "../lib/openzeppelin/contracts/interfaces/IERC20.sol";

/**
* @author AVZ.Tech
* @notice User interacts with this contract trough `main.sol`
*         Type1 means that user can use this contract as wallet to hold Funds
*/
contract WalletContract {

    mapping(address => bool) public owners; 

    IFunctions public functions;

    constructor(address _owner, address _secondOwner) {
        owners[_owner] = true;
        if(_secondOwner != address(0)) owners[_secondOwner] = true; 
        functions = IFunctions(address(0x123));
    }

    /** 
    * @notice only allows MAIN to call this function using msg.sender for @param _signer
    *         So onlyOwner can call this.contract.function from MAIN contract
    * @dev check if msg.sender is MAIN
    * @dev check if msg.sender in the MAIN.function is a allowed owner  
    */
    modifier accessControl(address _signer){
        require(/*ONLYMAIN*/0==0);
        require(owners[_signer], "onlyOwner control");
        _;
    }

      /////////////////////////////////////////////
     /////////////////  ERRORS  //////////////////
    /////////////////////////////////////////////
    error InvalidParams(string functionName);
    error MaxParamsReached(uint256 totalParms);


      ////////////////////////////////////////////
     /////////////////  EVENTS  /////////////////
    ////////////////////////////////////////////
    event EtherReceived(address indexed sender, uint256 amount);
    event DeFiActionExecuted(bytes4 functionSelector, ParamManagerLib.DeFiParam[] params);
    event ContractFunded(address token, uint256 value);

      ////////////////////////////////////////////
     ////////////////  MAPPINGS  ////////////////
    ////////////////////////////////////////////
    mapping(address => uint256) internal portfolio;

    receive() external payable{
        require(msg.value > 0, "Send more Ether");
        emit EtherReceived(msg.sender, msg.value);
    }

    function depositFunds(address _token, uint256 _value) public payable {
        if(_token == address(0) && msg.value == 0) revert InvalidParams("depositFunds");
        if(_token != address(0) && msg.value > 0) revert InvalidParams("depositFunds");
        if(_token != address(0) && _value == 0) revert InvalidParams("depositFunds");
        uint256 value;
        if(_token == address(0)){
            value = msg.value;
        } else {
            value = _value;
            IERC20(_token).transferFrom(msg.sender, address(this), _value);
            portfolio[_token] += _value;
        }
        emit ContractFunded(_token, value);
    }

    function defiAction(bytes calldata _actionData, address _signer) public payable accessControl(_signer) {
        bytes4 functionSelector = abi.decode(_actionData[:4], (bytes4));
        uint256[] memory paramsTypes = abi.decode(_actionData[4:36], (uint256[]));
        if(paramsTypes.length > 10) revert MaxParamsReached(paramsTypes.length);
        ParamManagerLib.DeFiParam[] memory params = new ParamManagerLib.DeFiParam[](paramsTypes.length);
        uint256 offset = 36; // (FuncSelector == 4) +(ParamsTypesArray == 32) == 36
        for(uint256 i = 0; i < paramsTypes.length; i++){
            ParamManagerLib.DeFiParam memory param;
            if(paramsTypes[i] == 0){
                param._type = 0;
                param.w = abi.decode(_actionData[offset:offset+32], (address));
            } else if(paramsTypes[i] == 1){
                param._type = 1;
                param.x = abi.decode(_actionData[offset:offset+32], (uint256));
            } else if(paramsTypes[i] == 2){
                param._type = 2;
                param.y = abi.decode(_actionData[offset:offset+32], (int256));
            } else if(paramsTypes[i] == 3){
                param._type = 3;
                param.z = abi.decode(_actionData[offset:offset+32], (bool));
            } else {
                revert InvalidParams("action");
            }
            params[i] = param;
            offset += 32;
        }
        functions.functionRouter{value : msg.value}(functionSelector, params);
        emit DeFiActionExecuted(functionSelector, params);
    }


      ////////////////////////////////////////////
     ////////////  READ FUNCTIONS  //////////////
    ////////////////////////////////////////////

    function getContractEtherBalance() public view returns(uint256){
        return address(this).balance;
    }

}