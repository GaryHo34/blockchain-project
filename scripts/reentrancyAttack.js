const hre = require("hardhat");

async function main() {
  const attackerBalance = hre.ethers.parseEther("10");

  const attacker = await hre.ethers.deployContract("Attacker", {
    value: attackerBalance,
  });

  await attacker.waitForDeployment();

  const bankBalance = hre.ethers.parseEther("10");

  const bankContract = await hre.ethers.deployContract(
    "EtherBankWithReentrancyGuard",
    {
      value: bankBalance,
    }
  );

  await bankContract.waitForDeployment();

  const bankAddress = await bankContract.getAddress();

  await attacker.setEtherBankAddress(bankAddress);

  await attacker.attack();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
