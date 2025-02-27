//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract MockIPoolAddressProider {

    address oracle;

    constructor(address _oracle){
        oracle = _oracle;
    }   

    function getPriceOracle() external view returns (address){
        return oracle;    
    }

}