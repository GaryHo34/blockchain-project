const hre = require("hardhat");

async function main() {
  const userBalance = hre.ethers.parseEther("10");

  const userContract = await hre.ethers.deployContract("User", [], {
    value: userBalance,
  });

  await userContract.waitForDeployment();

  const bankContract = await hre.ethers.deployContract("EtherBankWithoutGuard");

  await bankContract.waitForDeployment();

  const bankAddress = await bankContract.getAddress();

  await userContract.setEtherBankAddress(bankAddress);

  await userContract.deposit();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
