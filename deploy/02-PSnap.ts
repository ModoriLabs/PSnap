import { DeployFunction } from "hardhat-deploy/dist/types";

const deployFn: DeployFunction = async function (hre) {
    const { deployments, getNamedAccounts } = hre
    const { deploy } = deployments
    const { deployer} = await getNamedAccounts()
    console.log("deployer: ", deployer);

    await deploy("PSnap", {
      from: deployer,
      log: true,
      args: [],
    })
}

deployFn.tags = ["local", "testnet", "mainnet", "PSnap"]
export default deployFn
