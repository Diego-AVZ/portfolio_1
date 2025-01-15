//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "./Params.sol";

library DataDecoder {

    error MaxParamsReached(uint256 totalParms);
    error InvalidParams(string functionName);


    function dataDecoder(bytes calldata _data) internal pure returns(bytes4, ParamManagerLib.DeFiParam[] memory){
        bytes4 functionSelector = abi.decode(_data[:4], (bytes4));
        uint256[] memory paramsTypes = abi.decode(_data[4:36], (uint256[]));
        if(paramsTypes.length > 10) revert MaxParamsReached(paramsTypes.length);
        ParamManagerLib.DeFiParam[] memory params = new ParamManagerLib.DeFiParam[](paramsTypes.length);
        uint256 offset = 36; // (FuncSelector == 4) +(ParamsTypesArray == 32) == 36
        for(uint256 i = 0; i < paramsTypes.length; i++){
            ParamManagerLib.DeFiParam memory param;
            if(paramsTypes[i] == 0){
                param._type = 0;
                param.w = abi.decode(_data[offset:offset+32], (address));
            } else if(paramsTypes[i] == 1){
                param._type = 1;
                param.x = abi.decode(_data[offset:offset+32], (uint256));
            } else if(paramsTypes[i] == 2){
                param._type = 2;
                param.y = abi.decode(_data[offset:offset+32], (int256));
            } else if(paramsTypes[i] == 3){
                param._type = 3;
                param.z = abi.decode(_data[offset:offset+32], (bool));
            } else {
                revert InvalidParams("dataDecoder");
            }
            params[i] = param;
            offset += 32;
        }
        return(functionSelector, params);
    }
}