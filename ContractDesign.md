## Contract design

We design a contract with simple deposit and withdraw functions and a user contract to interact with the bank contract. on the other hand, an attacker contract is designed to attack the bank contract.

```mermaid
classDiagram
    class Bank {
        -mapping balance
        +deposit()
        +transfer()
        +withdrawAll()
        +getBalance()
        +getUserBalance()
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
        +attack()
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
    Attacker->>Bank: invoke withdraw function
    loop
        Bank->>Bank: Check Attacker's balance > 0
        Bank->>Attacker: Send ether, trigger fallback function
        Attacker->>Bank: fallback function call withdraw function again
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
    Attacker->>Bank: invoke withdraw function
    Bank->>Bank: Lock withdraw function
    Bank->>Attacker: Send ether, trigger fallback function
    Attacker->>Bank: fallback function call withdraw function again
    Break when the mutex lock is true
        Bank->>Attacker: Revert
    end
```

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
        +transfer()
        +withdrawAll()
        +getBalance()
        +getUserBalance()
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
        +attack()
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
    participant Attacker
    participant BankProxy
    participant Bank
    Attacker->>BankProxy: invoke withdraw function
    BankProxy->>BankProxy: Lock all function call to Bank
    BankProxy->>Bank: invoke withdraw function
    Bank->>Attacker: Send ether, trigger fallback function
    Attacker->>BankProxy: fallback function call withdraw function again
    Break when the mutex lock is true
        BankProxy->>Attacker: Revert
    end
```

## Cross Function Reentrancy Attack

In cross function reentrancy attack, the attacker will attack the contract with its accomplice. They invoke withdraw and transfer function of the bank contract alternatively. The withdraw function will be done for each withdraw call, because the function being attacked is different from the function being called. The attacker can withdraw money from the bank contract infinitely.

```mermaid
sequenceDiagram
    participant Attacker
    participant Accomplice
    participant BankWithReentrancyGuard
    Attacker->>BankWithReentrancyGuard: invoke withdraw function
    loop
        BankWithReentrancyGuard->>BankWithReentrancyGuard: Lock the withdraw function
        BankWithReentrancyGuard->>Attacker: Send ether, trigger receive function
        Attacker->>BankWithReentrancyGuard: invoke transfer function, transfer money to Accomplice
        BankWithReentrancyGuard->>BankWithReentrancyGuard: transfer money to Accomplice's balance
        BankWithReentrancyGuard->>BankWithReentrancyGuard: Update Attackers's balance
        BankWithReentrancyGuard->>BankWithReentrancyGuard: Unlock the withdraw function
        Accomplice->>BankWithReentrancyGuard: invoke withdraw function again
    end
```
