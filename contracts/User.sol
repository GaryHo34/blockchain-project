// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "./EtherBank.interface.sol";
import "hardhat/console.sol";

contract User {
    IEtherBank public etherBank;

    constructor() payable {}

    function setEtherBankAddress(address payable _etherBankAddress) external {
        etherBank = IEtherBank(_etherBankAddress);
    }

    receive() external payable {}

    function deposit() external payable {
        etherBank.deposit{value: 1 ether}();
        console.log("User balance: %s", address(this).balance/1 ether);
    }
}
