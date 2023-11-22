#!/bin/bash

for guard_name in "No Guard" "ReentrancyGuard" "ProxyGuard" "BalanceGuard"
    do
        printf "\n\n========= Execute reentrancy attack on contract with $guard_name =========\n\n"
        REENTRANCY_GUARD=$guard_name npx hardhat run scripts/singleFunctionReentrancyAttack.js 
    done
