// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "./EtherBank.interface.sol";
import "hardhat/console.sol";

contract User {
    IEtherBank private etherBank;

    constructor() payable {}

    function setEtherBankAddress(address payable _etherBankAddress) external {
        etherBank = IEtherBank(_etherBankAddress);
    }

    function withdraw() external {
        etherBank.withdrawAll();
        console.log(
            "Account balance: %s, Bank balance: %s",
            address(this).balance / 1 ether,
            etherBank.getBalance() / 1 ether
        );
    }

    receive() external payable {
        console.log("User received: %s", address(this).balance / 1 ether);
    }

    function deposit() external payable {
        etherBank.deposit{value: 1 ether}();
        console.log(
            "Account balance: %s, Bank balance: %s",
            address(this).balance / 1 ether,
            etherBank.getBalance() / 1 ether
        );
    }
}
