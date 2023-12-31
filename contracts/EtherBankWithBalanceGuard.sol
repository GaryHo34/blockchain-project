// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

contract EtherBankWithBalanceGuard {
    uint256 private _participantsLiquidity;
    uint256 private _beforeOperation;
    uint256 private _afterOperation;
    mapping(address => uint256) private _userBalances;
    bool private mutex;

    modifier balanceGuard() {
        require(
            this.getBalance() == this.getParticipantsLiqudity(),
            "Balance Guard: Unmatched liquidity."
        );
        _;
    }

    constructor() payable {
        _participantsLiquidity = address(this).balance;
        _beforeOperation = 0;
        _afterOperation = 0;
    }

    function deposit() external payable {
        require(msg.value > 0, "Value must be greater than 0.");
        _userBalances[msg.sender] += msg.value;
        _afterOperation = this.getBalance() - _beforeOperation; // the increment of the contract balance
        _participantsLiquidity += _afterOperation; // the increment is added to the participants liquidity
        _beforeOperation = this.getBalance(); // the balance before the operation is updated
        _afterOperation = 0;
    }

    function transfer(address receiver, uint256 _amount) external balanceGuard {
        require(_userBalances[msg.sender] >= _amount, "Insufficient balance.");
        _userBalances[receiver] += _amount;
        _userBalances[msg.sender] -= _amount;
    }

    function withdrawAll() external balanceGuard {
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
        _participantsLiquidity -= balance;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getParticipantsLiqudity() external view returns (uint256) {
        return _participantsLiquidity;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return _userBalances[_user];
    }

    receive() external payable {}

    fallback() external payable {}
}
