const hre = require("hardhat");

const INIT_BALANCE = hre.ethers.parseEther("10");
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

async function main() {
  const bank = await bankContractFactory();

  await bank.waitForDeployment();

  let bankAddress = await bank.getAddress();

  if (GUARD_NAME === "ProxyGuard") {
    const [deployer] = await hre.ethers.getSigners();
    const signer = await deployer.getAddress();
    const proxy = await hre.ethers.deployContract("ReentrancyGuardProxy", [
      bankAddress,
      signer,
      "0x00",
    ]);

    await proxy.waitForDeployment();

    bankAddress = await proxy.getAddress();
  }

  const attacker1 = await hre.ethers.deployContract("CrossFunctionAttacker", {
    value: INIT_BALANCE,
  });

  const attacker2 = await hre.ethers.deployContract("CrossFunctionAttacker", {
    value: INIT_BALANCE,
  });
  await attacker1.waitForDeployment();
  await attacker2.waitForDeployment();

  const atk1Addr = await attacker1.getAddress();
  const atk2Addr = await attacker2.getAddress();

  await attacker1.setEtherBankAddress(bankAddress);
  await attacker1.setAccompliceAddress(atk2Addr);

  await attacker2.setEtherBankAddress(bankAddress);
  await attacker2.setAccompliceAddress(atk1Addr);

  await attacker1.attackInit();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});