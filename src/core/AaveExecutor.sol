//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Roles} from "../admins/Roles.sol";
import {IPool} from "../../lib/aave/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "../../lib/aave/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "../../lib/aave/contracts/interfaces/IPriceOracle.sol";
import {DataTypes} from "../../lib/aave/contracts/protocol/libraries/types/DataTypes.sol";
import {IERC20} from "../../lib/openzeppelin/contracts/interfaces/IERC20.sol";

contract AaveExecutor {

    address public constant AAVE_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
    address public constant ADDRESSES_PROV = 0xe20fCBdBfFC4Dd138cE8b2E6FBb6CB49777ad64D;

    constructor(address _roles){
        roles = Roles(_roles);
    }

    modifier accessControl(){
        require(roles.isProtocolContract(msg.sender), "Access Control: Only Protocols");
        _;
    }

    error SupplyAaveParamError();
    error InsufficientBorrowPower();

    struct aToken {
        address token;
        uint256 balance;
    }

    mapping(address => aToken[]) internal aTokensBalances;

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
            IERC20(_asset).transferFrom(_sender, address(this), _amount);
            IERC20(_asset).approve(AAVE_POOL, _amount);
            IPool(AAVE_POOL).supply(_asset, _amount, _sender, 0);
            address aToken = IPool(AAVE_POOL).getReserveData(_asset);
            uint256 balance = IERC20(aToken).balanceOf(_sender);
            aTokensBalances[_sender][aToken] = balance;
            emit SuppliedToAave(_sender, _asset, _amount);
    }


    function borrowAave(
            address _asset, 
            uint256 _amount, 
            address _sender
        ) internal accessControl returns(bool) {
            if(
                calculateBorrowPower();
            ) revert InsufficientBorrowPower();
            IPool(AAVE_POOL).borrow(_asset, _amount, 2, 0, _sender);
            return true;
    }

    function calculateBorrowPower(address _asset) public view returns(uint256 ) {
        ReserveConfigurationMap memory config = IPool(AAVE_POOL).getReserveData(_asset).configuration;
        uint256 LTV = config.data & (1 << 16 - 1);
        address oracle = IPoolAddressesProvider(ADDRESSES_PROV).getPriceOracle();
        uint256 price = IPriceOracle(oracle).getAssetPrice(_asset);
        
    }

}