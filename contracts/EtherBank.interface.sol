// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

interface IEtherBank {
    function deposit() external payable;

    function transfer(address receiver, uint256 _amount) external;

    function withdrawAll() external;

    function getBalance() external view returns (uint256);

    function getUserBalance(address _user) external view returns (uint256);
}