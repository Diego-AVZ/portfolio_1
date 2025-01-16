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
            portfolio[_token] += _value;
        }
        emit ContractFunded(_token, value);
    }

    function defiAction(bytes[] calldata _actionData, address _signer) public payable accessControl(_signer) {
        (bytes4 functionSelector, ParamManagerLib.DeFiParam[] memory params) = _actionData.dataDecoder();
        functions.functionRouter{value : msg.value}(functionSelector, params);
        emit DeFiActionExecuted(functionSelector, params);
    }


    // INteract with anothe protocol
    /*  
        Protocol crea un CustomMain{} que llama a nuestro Main (a CustomMain le llamarán desde su front)
        Protocol tiene su contract y su funcion a la que quiere llamar
        1. buildHexData(); con funcitonSelector
        2. Mi MAIN.mainDefiActionCustom(hexData) llama con hexData
        3 en este contrato
        function extraDefiActions(){
            hace llamada .call con msg.data para que el fallback del contrato de Protocol lo detecte
            * problema es que e fallback debe estar diseñada para pillar la data
            * el protocol debera desplegar otro contrato con la interface a llamar y la address a llamar
            * voy a crear un nuevo contrato a modo de SDK para que los protocols puedan usarlo y configurarlo facilmente
        }
    */

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