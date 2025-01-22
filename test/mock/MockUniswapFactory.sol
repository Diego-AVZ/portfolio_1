//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; 

contract MockUniswapFactory {

    address public constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public constant AAVE = 0xD6DF932A45C0f255f85145f286eA0b292B21C90B;

 
    mapping(address => mapping(address => mapping(uint24 => address))) public getPool;

    constructor(address poolA, address poolB, address poolC){
        getPool[WETH][AAVE][100] = poolA;
        getPool[WETH][AAVE][500] = poolB;
        getPool[WETH][AAVE][3000] = poolC;
    }

}