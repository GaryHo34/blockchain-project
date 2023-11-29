// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

contract EtherBankWithoutGuard {
    mapping(address => uint256) private _userBalances;

    constructor() payable {}

    function deposit() external payable {
        _userBalances[msg.sender] += msg.value;
    }

    function transfer(address receiver, uint256 _amount) external {
        require(_userBalances[msg.sender] >= _amount, "Insufficient balance.");
        _userBalances[receiver] += _amount;
        _userBalances[msg.sender] -= _amount;
    }

    function withdrawAll() external {
        uint256 balance = _userBalances[msg.sender];
        require(balance > 0, "Insufficient balance.");
        (bool success, bytes memory returndata) = msg.sender.call{
            value: balance
        }("");

        if (!success) {
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("Failed to send Ether");
            }
        }

        _userBalances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return _userBalances[_user];
    }

    receive() external payable {}

    fallback() external payable {}
}
