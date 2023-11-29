const BALANCE = process.env.BALANCE ?? "10";

const INIT_BALANCE = hre.ethers.parseEther(BALANCE);

const GUARD_NAME = process.env.REENTRANCY_GUARD;

const bankContractFactory = async () => {
  let contractName;

  switch (GUARD_NAME) {
    case "BalanceGuard":
      contractName = "EtherBankWithBalanceGuard";
      break;
    case "ReentrancyGuard":
      contractName = "EtherBankWithReentrancyGuard";
      break;
    default:
      contractName = "EtherBankWithoutGuard";
      break;
  }

  return await hre.ethers.deployContract(contractName, {
    value: INIT_BALANCE,
  });
};

module.exports = { INIT_BALANCE, GUARD_NAME, bankContractFactory };