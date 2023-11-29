#!/bin/bash

echo "============== Scenario 1: Single Function Reentrancy Attack =============="
for guard_name in "No Guard" "ReentrancyGuard" "ProxyGuard" "BalanceGuard"
    do
        printf "\n\n\n\n========= Testing $guard_name =========\n\n"
        REENTRANCY_GUARD=$guard_name BALANCE=5 npx hardhat run scripts/singleFunctionReentrancyAttack.js 
    done

printf "\n\n\n\n============== Scenario 2: Cross Function Reentrancy Attack =============="
for guard_name in "No Guard" "ReentrancyGuard" "ProxyGuard" "BalanceGuard"
    do
        printf "\n\n\n\n========= Testing $guard_name =========\n\n"
        REENTRANCY_GUARD=$guard_name BALANCE=5 npx hardhat run scripts/crossFunctionReentrancyAttack.js 
    done
