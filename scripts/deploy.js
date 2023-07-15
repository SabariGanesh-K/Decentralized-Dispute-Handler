// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  let subscriptionId; //chainlink subscription id
  const consumerContract = await hre.ethers.getContractFactory("VRFv2Consumer");
  const consumerContractDeploy = await consumerContract.deploy(subscriptionId);

  await consumerContractDeploy.deployed();

  console.log(
    `VRFv2Consumer contract deployed to ${consumerContractDeploy.address} in sepolia testnet`
  );

  const disputeHandlerContract = await hre.ethers.getContractFactory(
    "DisputeHandler"
  );
  const disputeHandlerContractDeploy = await disputeHandlerContract.deploy(
    consumerContractDeploy.address
  );

  await disputeHandlerContractDeploy.deployed();
  console.log(
    `DisputeHandler contract deployed to ${disputeHandlerContractDeploy.address} in sepolia testnet`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
