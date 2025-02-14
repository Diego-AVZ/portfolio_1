//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Roles} from "../admins/Roles.sol";
import {IPool} from "../../lib/aave/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "../../lib/aave/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "../../lib/aave/contracts/interfaces/IPriceOracle.sol";
import {DataTypes} from "../../lib/aave/contracts/protocol/libraries/types/DataTypes.sol";
import {IERC20} from "../../lib/openzeppelin/contracts/interfaces/IERC20.sol";
import {AaveUtils} from "../lib/Aave/AaveUtils.sol";

contract AaveExecutor {

    address public constant AAVE_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
    Roles public roles;

    constructor(address _roles){
        roles = Roles(_roles);
    }

    modifier accessControl(){
        require(roles.isProtocolContract(msg.sender), "Access Control: Only Protocols");
        _;
    }

    error SupplyAaveParamsError();
    error InsufficientBorrowPower();

    event SuppliedToAave(address indexed, address, uint256);
    event BorrowwedFromAave(address indexed, address, uint256);

    mapping(address => AaveUtils.AaveToken[]) internal aTokensBalances;
    mapping(address => uint256) internal userBorrowsInBase;

    function supplyAave(
            address _asset,
            uint256 _amount,
            address _sender
        ) external accessControl {
            if(
                _asset == address(0) ||
                _sender == address(0) ||
                _amount == 0
            ) revert SupplyAaveParamsError();
            addAToken(_asset, _sender, _amount);
            IERC20(_asset).transferFrom(_sender, address(this), _amount);
            IERC20(_asset).approve(AAVE_POOL, _amount);
            IPool(AAVE_POOL).supply(_asset, _amount, _sender, 0);
            emit SuppliedToAave(_sender, _asset, _amount);
    }

    function addAToken(address _asset, address _acccount, uint256 amount) internal {
        address aToken = AaveUtils.getReserveData(_asset);
        AaveUtils.AaveToken[] storage aaveTokens = aTokensBalances[_acccount];
        uint8 index = AaveUtils.reviewATokens(aToken, aaveTokens);
        if(index != 255){
            aTokensBalances[_acccount][index].balance += amount;
        } else {
            AaveUtils.AaveToken memory aaveToken = AaveUtils.AaveToken(aToken, amount);
            aTokensBalances[_acccount].push(aaveToken);
        }
    }

    function borrowAave(
            address _asset, 
            uint256 _value, // In Base Coin (usdc) 
            address _sender
        ) 
        internal 
        accessControl 
        returns(bool) {
            AaveUtils.AaveToken[] storage aaveTokens = aTokensBalances[_sender];
            if(
                _value < AaveUtils.calculateMaxBorrowPower(aaveTokens) - userBorrowsInBase[_sender]
            ) revert InsufficientBorrowPower();
            userBorrowsInBase[_sender] += _value;
            uint256 amount = AaveUtils.valueToAmount(_asset, _value);
            IPool(AAVE_POOL).borrow(_asset, amount, 2, 0, _sender);
            IERC20(_asset).transfer(_sender, amount);
            return true;
    }

    function reduceATokens(address _asset, address _account, uint256 amount) internal {
        address aToken = AaveUtils.getReserveData(_asset);
        AaveUtils.AaveToken[] storage aaveTokens = aTokensBalances[_account];
        uint8 index = AaveUtils.reviewATokens(aToken, aaveTokens);
        if(index != 255){
            aTokensBalances[_account][index].balance -= amount;
        }
    }

    
}