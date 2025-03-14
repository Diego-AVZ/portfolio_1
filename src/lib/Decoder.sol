//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ParamManagerLib} from "./Params.sol";

library DataDecoder {

    error MaxParamsReached(uint256 totalParms);
    error InvalidParams(string functionName);
    /** 
    */
    function dataDecoder(bytes[] calldata _data) external pure returns(bytes4, ParamManagerLib.DeFiParam[] memory){
        bytes4 functionSelector = bytes4(_data[0]);
        uint256[] memory paramsTypes = abi.decode(_data[1], (uint256[]));
        if(paramsTypes.length > 10) revert MaxParamsReached(paramsTypes.length);
        ParamManagerLib.DeFiParam[] memory params = new ParamManagerLib.DeFiParam[](paramsTypes.length);
        uint256 offset = 0; 
        for(uint256 i = 0; i < paramsTypes.length; i++){
            ParamManagerLib.DeFiParam memory param;
            if(paramsTypes[i] == 0){
                param._type = 0;
                param.w = abi.decode(_data[2][offset:offset+32], (address));
            } else if(paramsTypes[i] == 1){
                param._type = 1;
                param.x = abi.decode(_data[2][offset:offset+32], (uint256));
            } else if(paramsTypes[i] == 2){
                param._type = 2;
                param.y = abi.decode(_data[2][offset:offset+32], (int256));
            } else if(paramsTypes[i] == 3){
                param._type = 3;
                param.z = abi.decode(_data[2][offset:offset+32], (bool));
            } else if(paramsTypes[i] == 4){
                param._type = 4;
                param.v = _data[2][offset:offset+32];
            } else {
                revert InvalidParams("dataDecoder");
            }
            params[i] = param;
            offset += 32;
        }
        return(functionSelector, params);
    }

}