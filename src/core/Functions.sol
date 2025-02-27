//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {MainDataStorage} from "./MainDataStorage.sol";
import {ParamManagerLib} from "../lib/Params.sol";
import {ISwapRouter02} from "../../lib/v3-periphery/contracts/interfaces/ISwapRouter02.sol";
import {IV3SwapRouter} from "../../lib/v3-periphery/contracts/interfaces/IV3SwapRouter.sol";
import {IUniswapV3PoolState} from "../../lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol";
import {PoolSearcher} from "../lib/UniswapPoolSearch.sol";
import {WalletContract} from "./WalletContract.sol";
import {UniswapUtils} from "../lib/UniswapUtils.sol";
import {IERC20} from "../../lib/openzeppelin/contracts/interfaces/IERC20.sol";
import {IPool} from "../../lib/aave/contracts/interfaces/IPool.sol";
import {DataTypes} from "../../lib/aave/contracts/protocol/libraries/types/DataTypes.sol";
import {ReentrancyGuard} from "../../lib/openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Functions is ReentrancyGuard {

    MainDataStorage public data;

    constructor(address _data){
        data = MainDataStorage(_data);
    }

    /** ARBITRUM
    address public constant SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant UNI_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address public constant AAVE_POOL = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    */
    /**BASE*/ 
    address public constant SWAP_ROUTER = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address public constant UNI_V3_FACTORY = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;
    address public constant AAVE_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
     
    /**ETH_SEPOLIA
    address public constant SWAP_ROUTER = 0x6b2937Bde17889EDCf8fbD8dE31C3C2a70Bc4d65;
    address public constant UNI_V3_FACTORY = 0x248AB79Bbb9bC29bB72f7Cd42F17e054Fc40188e;
    address public constant AAVE_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
    */

    event SuppliedToAave(address indexed user, address asset, uint256 amount);


    error InvalidParams(string functionName);

    /*
    modifier accessControl(){
        bool isValidContract = data.getUserData(msg.sender).contractAddress != address(0);
        require(isValidContract, "access control: only valid contracts");
        _;
    }
    */
    /**
    * @notice Routes parameters to the corresponding function in the contract to execute the actions based on the function selector.
    * @dev This function is called from WalletContracts with two inputs: 
    *      - _functSelector: a bytes4 that refers to the internal function to call.
    *      - _params: an array of DeFiParam structs containing the necessary parameters.
    *      DeFiParam is a struct of types:
    *      - 'v' for bytes
    *      - 'w' for addresses
    *      - 'x' for uints
    *      - 'y' for ints
    *      - 'z' for bool
    * @dev accessControl allows only contracts created with Factory can sign this function
    * @param _funcSelector The bytes4 function selector to determine which internal function to call.
    * @param _params An array of DeFiParam structs containing the parameters needed by the function being called.
    * @return success Returns a boolean indicating whether the operation was successful.
    */
    function functionRouter(
            bytes4 _funcSelector, 
            ParamManagerLib.DeFiParam[] memory _params
        ) external 
        //accessControl 
        nonReentrant 
        returns(
            bool
        ){
            bytes4 f = _funcSelector;
            ParamManagerLib.DeFiParam[] memory p = _params;
            bool success;
            if(f == 0xee5b3814){
                success = swap(
                    p[0].w, 
                    p[1].w, 
                    p[2].x, 
                    p[3].x
                );
            } else if(f == 0x88bd413e){
                addLiquidity01(
                    p[0].x, 
                    uint24(p[1].x),
                    int24(p[2].y),
                    int24(p[3].y),
                    p[4].x, 
                    p[5].x
                );
            }else if(f == 0x469e635e){
                success = uniswapSwap(
                    p[0].w, 
                    p[1].w, 
                    msg.sender, 
                    p[2].x, 
                    p[3].x
                );

            } else {
                revert("Invalid function selector");
            }
            return success;
    }

    function swap(
            address tokenIn,
            address tokenOut,
            uint256 amountIn,
            uint256 amountOutMin
        ) internal returns(bool){
        /*executor.swap();*/
        return true;
    }

    function addLiquidity01(
            uint256 pair,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint256 amount0,
            uint256 amount1
        ) internal {
        /*executor.addLiquidity01();*/
    }

    function uniswapSwap(
            address tokenIn,
            address tokenOut,
            address sender,
            uint256 amountIn,
            uint256 slippage
        ) internal returns(bool){
            //require(msg.sender == address(this), "Access control");
            address pool = PoolSearcher.searchPool(tokenIn, tokenOut, UNI_V3_FACTORY);
            uint24 fee = UniswapUtils.getPoolFee(pool);
            address[] memory path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
            uint256 amountOutMin = UniswapUtils.getAmountOutMin(pool, slippage, amountIn, path);
            uint160 sqrtPriceLimitX96 = UniswapUtils.getLimitSqrtPrice(pool, slippage, path);
            IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams(
                {
                    tokenIn : tokenIn,
                    tokenOut : tokenOut,
                    fee : fee,
                    recipient : address(this),
                    amountIn : amountIn,
                    amountOutMinimum : amountOutMin,
                    sqrtPriceLimitX96 : sqrtPriceLimitX96
                }
            );
            IERC20(tokenIn).transferFrom(sender, address(this), amountIn);
            IERC20(tokenIn).approve(SWAP_ROUTER,amountIn);
            uint256 amountOut = ISwapRouter02(SWAP_ROUTER).exactInputSingle(params);
            /* RETURN FUNDS TO WALLET_CONTRACT
                WalletContract(payable(sender)).depositFunds{ value : 0 }(tokenOut, amountOut);
            */
            return(amountOut >= amountOutMin);
    }

    
    function supplyAave(
            address _asset,
            uint256 _amount,
            address _sender
        ) internal {
            if(
                _asset == address(0) ||
                _sender == address(0) ||
                _amount == 0
            ) revert InvalidParams("supplyAave");
            IERC20(_asset).transferFrom(_sender, address(this), _amount);
            IERC20(_asset).approve(AAVE_POOL, _amount);
            IPool(AAVE_POOL).supply(_asset, _amount, address(this), 0);
            emit SuppliedToAave(_sender, _asset, _amount);
    }


    function borrowAave(
            address _asset, 
            uint256 _amount, 
            address _sender
        ) internal returns(bool) {
            IPool(AAVE_POOL).borrow(_asset, _amount, 2, 0, _sender);
            return true;
    }

    function approveRequired(bytes4 _funcSelector) external pure returns(bool isRequired, uint8[] memory, uint8[] memory, uint8 approvals){
        bytes4 f = _funcSelector;
        uint8[] memory tokens = new uint8[](5);
        uint8[] memory amounts = new uint8[](5);
        if(f == 0xee5b3814){
            //
            isRequired = false;
        } else if(f == 0x88bd413e){
            //
        } else if(f == 0x469e635e){
            //uniswapSwap();
            isRequired = true;
            approvals = 1;
            tokens[0] = 0;
            amounts[0] = 3;
        } else {
            revert("Invalid function selector");
        }
        return(isRequired, tokens, amounts, approvals);
    }

}