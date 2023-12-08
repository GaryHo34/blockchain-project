# Blockchain Project

This project is a simple bank contract with reentrancy attack and defense.
Written in Solidity and tested using Hardhat.

## Prerequisite

| Name | Version            |
| ---- | ------------------ |
| OS   | Linux / MaxOS      |
| node | v16 to v20         |
| yarn | v1.22.10 or higher |

## Installation

Strongly recommend install all the dependencies using yarn. Npm may cause some problems.

```bash
yarn install
```

## Run the demo

We write a simple script to demonstrate the reentrancy attack and defense.

```bash
bash demo.sh
```

To run the test for each type of reentrancy guard. Pass the guard name as an environment variable to the script. The available guards are:
- ReentrancyGuard
- BalanceGuard
- ProxyGuard

To run Single Function Reentrancy Attack test with specific guard, replace `<guard_name>` with the guard name:

```bash
REENTRANCY_GUARD=<guard_name> npx hardhat run scripts/singleFunctionReentrancyAttack.js
```

To run Cross Function Reentrancy Attack test with specific guard, replace `<guard_name>` with the guard name:

```bash
REENTRANCY_GUARD=<guard_name> npx hardhat run scripts/crossFunctionReentrancyAttack.js
```

Noted that if no guard name is passed, the script will run the test without any type of Reentrancy Guard.