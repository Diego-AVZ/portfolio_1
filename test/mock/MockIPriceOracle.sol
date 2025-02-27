//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract MockIPriceOracle {

    function getAssetPrice(address asset) external pure returns (uint256){
        return 1000;
    }


}