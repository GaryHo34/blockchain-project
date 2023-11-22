// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

contract EtherBankWithReentrancyGuard {
    mapping(address => uint256) private _userBalances;
    bool private mutex;

    constructor() payable {}

    modifier reentrancyGuard() {
        require(mutex == false, "No reentrancy allowed.");
        mutex = true;
        _;
        mutex = false;
    }

    function deposit() external payable {
        _userBalances[msg.sender] += msg.value;
    }

    function transfer(address receiver, uint256 _amount) external reentrancyGuard {
        require(_userBalances[msg.sender] >= _amount, "Insufficient balance.");
        _userBalances[receiver] += _amount;
        _userBalances[msg.sender] -= _amount;
    }

    function withdrawAll() external reentrancyGuard {
        uint256 balance = _userBalances[msg.sender];
        require(balance > 0, "Insufficient balance.");

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");

        _userBalances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return _userBalances[_user];
    }

    receive() external payable {}

    fallback() external payable {}
}
