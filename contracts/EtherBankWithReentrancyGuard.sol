// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

contract EtherBankWithReentrancyGuard {
    constructor() payable {}

    mapping(address => uint256) private _userBalances;
    bool private mutex;

    modifier nonReentrant() {
        require(!mutex, "No re-entrancy");
        mutex = true;
        _;
        mutex = false;
    }

    function deposit() external payable {
        _userBalances[msg.sender] += msg.value;
    }

    function transfer(address receiver, uint256 _amount) external nonReentrant {
        require(_userBalances[msg.sender] >= _amount, "Insufficient balance.");
        _userBalances[receiver] += _amount;
        _userBalances[msg.sender] -= _amount;
    }

    function withdrawAll() external nonReentrant {
        uint256 balance = _userBalances[msg.sender];
        require(balance > 0, "Insufficient balance.");

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");

        _userBalances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return _userBalances[_user];
    }
}
