//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Roles} from "./admins/Roles.sol";
import {ParamManagerLib} from "./lib/Params.sol";
import {DataDecoder} from "./lib/Decoder.sol";
import {IFunctions} from "./interfaces/IFunctions.sol";
import {IERC20} from "../lib/openzeppelin/contracts/interfaces/IERC20.sol";

/**
* @author AVZ.Tech
* @notice User interacts with this contract trough `main.sol`
*         Type1 means that user can use this contract as wallet to hold Funds
*/
contract WalletContract {

    using DataDecoder for bytes[];

    mapping(address => bool) public owners; 

    IFunctions public functions;
    Roles public roles;

    constructor(address _owner, address _secondOwner, address _funct, address _roles) {
        owners[_owner] = true;
        if(_secondOwner != address(0)) owners[_secondOwner] = true; 
        functions = IFunctions(_funct);
        roles = Roles(_roles);
    }

    /** 
    * @notice only allows MAIN to call this function using msg.sender for @param _signer
    *         So onlyOwner can call this.contract.function from MAIN contract
    * @dev check if msg.sender is MAIN
    * @dev check if msg.sender in the MAIN.function is a allowed owner  
    */
    modifier accessControl(address _signer){
        bool isProtocol = roles.isProtocolContract(_signer);
        require(isProtocol, "access control: onlyProtocol");
        require(owners[_signer], "access control: onlyOwner");
        _;
    }

      /////////////////////////////////////////////
     /////////////////  ERRORS  //////////////////
    /////////////////////////////////////////////
    error InvalidParams(string functionName);

      ////////////////////////////////////////////
     /////////////////  EVENTS  /////////////////
    ////////////////////////////////////////////
    event EtherReceived(address indexed sender, uint256 amount);
    event DeFiActionExecuted(bytes4 functionSelector, ParamManagerLib.DeFiParam[] params);
    event ContractFunded(address token, uint256 value);

      ////////////////////////////////////////////
     ////////////////  MAPPINGS  ////////////////
    ////////////////////////////////////////////
    mapping(address => bool) internal isHolded;

    receive() external payable{
        require(msg.value > 0, "Send more Ether");
        emit EtherReceived(msg.sender, msg.value);
    }

    function depositFunds(address _token, uint256 _value) public payable {
        if(_token == address(0) && msg.value == 0 || 
           _token != address(0) && msg.value > 0 ||
           _token != address(0) && _value == 0 
        ) revert InvalidParams("depositFunds");
        uint256 value;
        if(_token == address(0)){
            value = msg.value;
        } else {
            value = _value;
            IERC20(_token).transferFrom(msg.sender, address(this), _value);
            isHolded[_token] = true;
        }
        emit ContractFunded(_token, value);
    }

    function withdrawFunds(address _token, uint256 _value, address _signer, address _recipient) public accessControl(_signer){
        IERC20(_token).transfer(_recipient, _value);
    }

    function defiAction(bytes[] calldata _actionData, address _signer) public payable accessControl(_signer) returns(bool) {
        (bytes4 functionSelector, ParamManagerLib.DeFiParam[] memory params) = _actionData.dataDecoder();
        (bool isRequired, uint8 token, uint8 amount) = functions.approveRequired(functionSelector);
        if(isRequired){
            approve(params[token].w, params[amount].x);
        }
        bool success = functions.functionRouter{value : msg.value}(functionSelector, params);
        emit DeFiActionExecuted(functionSelector, params);
        return success;
    }

    function approve(address _token, uint256 _amount) internal {
        IERC20(_token).approve(address(functions), _amount);
    }
    

    function extraDefiActions(bytes[] calldata _data, address _signer, address _customizedContract) external payable accessControl(_signer){
        (bytes4 functionSelector, ParamManagerLib.DeFiParam[] memory params) = _data.dataDecoder();
        IFunctions(_customizedContract).functionRouter{value : msg.value}(functionSelector, params);
    }


      ////////////////////////////////////////////
     ////////////  READ FUNCTIONS  //////////////
    ////////////////////////////////////////////

    function getContractEtherBalance() public view returns(uint256){
        return address(this).balance;
    }

}