# Blockchain Project

This project is a simple bank contract with reentrancy attack and defense.
Written in Solidity and tested using Hardhat.

## Prerequisite

| Name | Version                                 |
| ---- | --------------------------------------- |
| OS   | Linux or MaxOS                          |
| Node | v16.0.0 or higher (not support v21 yet) |
| yarn | v1.22.10 or higher                      |

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

You can also manually run the test for each type of reentrancy guard.
Pass the guard name as an environment variable to the script or run the script directly and no guard will be used.

the available guards are [ReentrancyGuard, BalanceGuard, ProxyGuard]

- for single function reentrancy attack

```bash
REENTRANCY_GUARD=<guard> npx hardhat run scripts/singleFunctionReentrancyAttack.js
```

- for cross function reentrancy attack

```bash
REENTRANCY_GUARD=<guard> npx hardhat run scripts/crossFunctionReentrancyAttack.js
```

## Contract design

We design a contract with simple deposit and withdraw functions and a user contract to interact with the bank contract. on the other hand, an attacker contract is designed to attack the bank contract.

```mermaid
classDiagram
    class Bank {
        -mapping balance
        +deposit()
        +withdraw()
    }
    class User {
        -address bank
        +deposit()
        +withdraw()
    }
    class Attacker {
        -address bank
        +deposit()
        +withdraw()
    }
    User *-- Bank
    Attacker *-- Bank
```

## Normal case

In the normal case, user can deposit and withdraw money from the bank contract.

```mermaid
sequenceDiagram
    participant User
    participant Bank
    User->>Bank: deposit 1 ehter
    User->>Bank: withdraw()
    Bank->>Bank: Check User's balance > 0
    Bank->>User: Send ether
```

## Reentrancy Attack

However in an reentrancy attack, the attacker hide its withdraw function and call the deposit function of the bank contract. The bank contract will transfer money to the attacker contract. Then the attacker contract will call the withdraw function of the bank contract to withdraw money again. The attacker contract can withdraw money from the bank contract infinitely.

```mermaid
sequenceDiagram
    participant Bank
    participant Attacker
    Attacker->>Bank: deposit 1 ether
    Bank->>Attacker: Send ether, trigger fallback function
    Attacker->>Bank: fallback(withdraw)
    loop
        Bank->>Bank: Check Attacker's balance > 0
        Bank->>Attacker: Send ether, trigger fallback function
        Attacker->>Bank: fallback(withdraw)
    end
```

## Defense

The simplest defense is a mutex lock to prevent reentrancy attack. The mutex lock is a boolean variable to indicate whether the contract is in a transaction. If the contract is in a transaction, the mutex lock is true. Otherwise, the mutex lock is false. The mutex lock is set to true at the beginning of a transaction and set to false at the end of a transaction. If the mutex lock is true, the contract will not execute the transaction.

```solidity
modifier noReentrant() {
    require(!locked, "No re-entrancy");
    locked = true;
    _;
    locked = false;
}
```

During the re-call of the withdraw function, the mutex lock will prevent the withdraw function from executing.

```mermaid
sequenceDiagram
 participant Bank
    participant Attacker
    Attacker->>Bank: deposit 1 ether
    Bank->>Attacker: Send ether, trigger fallback function
    Attacker->>Bank: fallback(withdraw)
    Bank->>Bank: Check Attacker's balance > 0
    Bank->>Bank: Lock withdraw function
    Bank->>Attacker: Send ether, trigger fallback function
    Attacker->>Bank: fallback(withdraw)
    Break when the mutex lock is true
        Bank->>Attacker: Revert
    end
```

## Drawbacks of mutex lock

Since the lock is a modifier, if we have one hundred methods in the Bank, we have to add lock to all of them. It is a tedious work. Moreover, if we forget to add lock to one of the methods, the contract is still vulnerable to reentrancy attack. Therefore, we need a better solution to prevent reentrancy attack.

## Proxy contract

Proxy contract is a common design pattern in smart contract. The proxy contract is a contract that can delegate its function calls to another contract. The proxy contract is a contract that can delegate its function calls to another contract. The proxy contract has a fallback function to delegate function calls to another contract. The proxy contract can be used to upgrade the contract without changing the address of the contract. The proxy contract can also be used to prevent reentrancy attack.

```mermaid
classDiagram
    class BankProxy {
        -address Bank
    }
    class Bank {
        -mapping balance
        +deposit()
        +withdraw()
    }
    class User {
        -address BankProxy
        +deposit()
        +withdraw()
    }
    class Attacker {
        -address BankProxy
        +deposit()
        +withdraw()
    }
    User *-- BankProxy
    Attacker *-- BankProxy
    BankProxy *-- Bank
```

```mermaid
sequenceDiagram
    participant User
    participant BankProxy
    participant Bank
    User->>BankProxy: deposit 1 ehter
    BankProxy->>Bank: deposit function call
    User->>BankProxy: withdraw()
    BankProxy->>Bank: withdraw function call
    Bank->>User: Send ether
```

So we can directly call the deposit and withdraw functions of the bank contract in the proxy contract. The proxy contract can prevent reentrancy attack by setting a mutex lock.

```mermaid
sequenceDiagram
    participant User
    participant BankProxy
    participant Bank
    User->>BankProxy: deposit 1 ehter
    BankProxy->>Bank: deposit function call
    User->>BankProxy: withdraw()
    BankProxy->>BankProxy: Check mutex lock
    BankProxy->>BankProxy: Lock all function call to Bank
    BankProxy->>Bank: withdraw function call
    Bank->>User: Send ether
    BankProxy->>BankProxy: Unlock all function call to Bank
```
