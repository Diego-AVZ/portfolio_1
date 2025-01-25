//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IWalletContract {

    function defiAction(bytes[] calldata _actionData, address _signer) external returns(bool);

    function depositFunds(address _token, uint256 _value) external payable;

    function withdrawFunds(address _token, uint256 _value, address _signer, address _recipient) external;

}