//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Roles} from "./admins/Roles.sol";
import {ParamManagerLib} from "./lib/Params.sol";
import {DataDecoder} from "./lib/Decoder.sol";
import {IFunctions} from "./interfaces/IFunctions.sol";
import {IERC20} from "../lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IWETH} from "../lib/weth/IWETH.sol";
import {ReentrancyGuard} from "../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
* @author AVZ.Tech
* @notice User interacts with this contract trough `main.sol`
*         Type1 means that user can use this contract as wallet to hold Funds
*/
contract WalletContract is ReentrancyGuard {

    using DataDecoder for bytes[];

    mapping(address => bool) public owners; 

    IFunctions public functions;
    Roles public roles;
    address public wEth;

    constructor(address _owner, address _secondOwner, address _funct, address _roles, address _wEth) {
        owners[_owner] = true;
        if(_secondOwner != address(0)) owners[_secondOwner] = true; 
        functions = IFunctions(_funct);
        roles = Roles(_roles);
        wEth = _wEth;
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
    mapping(address => bool) internal isLocked;

    receive() external payable{
        require(msg.value > 0, "Send more Ether");
        IWETH(wEth).deposit{value : msg.value}();
        isHolded[wEth] = true;
        emit EtherReceived(msg.sender, msg.value);
    }

    function depositFunds(address _signer, address _token, uint256 _value) external payable accessControl(_signer) nonReentrant() {
        if(
            _token == address(0) && msg.value == 0 || 
            _token != address(0) && msg.value > 0 ||
            _token != address(0) && _value == 0 
        ) revert InvalidParams("depositFunds");
        uint256 value;
        if(_token == address(0)){
            value = msg.value;
        } else {
            value = _value;
            IERC20(_token).transferFrom(_signer, address(this), _value);
            isHolded[_token] = true;
        }
        emit ContractFunded(_token, value);
    }

    function depositNonWithdrawableToken(address _signer, address _token, uint256 _amount) external accessControl(_signer){
        isLocked[_token] = true;
        depositFunds(_signer,_token, _ammount);
    }

    function withdrawFunds(address _token, uint256 _value, address _signer, address _recipient) public accessControl(_signer) nonReentrant(){
        IERC20(_token).transfer(_recipient, _value);
    }

    function defiAction(bytes[] calldata _actionData, address _signer) public accessControl(_signer) nonReentrant() returns(bool) {
        (bytes4 functionSelector, ParamManagerLib.DeFiParam[] memory params) = _actionData.dataDecoder();
        (bool isRequired, uint8[] memory tokens, uint8[] memory amounts, uint8 approvals) = functions.approveRequired(functionSelector);
        if(isRequired){
            for(uint8 i = 0; i < approvals; i++){
                approve(params[tokens[i]].w, params[amounts[i]].x);
            }
        }
        bool success = functions.functionRouter(functionSelector, params);
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

}