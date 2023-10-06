import { DeployFunction } from "hardhat-deploy/dist/types"

const ONE_WEEK = 60 * 60 * 24 * 7
const WAD = (10n ** 18n)

const deployFn: DeployFunction = async function (hre) {
  const { deployments, getNamedAccounts } = hre
  const { deploy, get } = deployments
  const { deployer} = await getNamedAccounts()
  const DSP = (await get("DSP")).address
  const MACH = (await get("MACH")).address

  const config = {
    exchangeRatio: 10n * WAD,
    maturity: 143 * ONE_WEEK,
    bonusPeriod: 50 * ONE_WEEK,
    minDeposit: 10000n * WAD,
    manager: deployer
  }

  await deploy("Migrator", {
    contract: "Migrator",
    from: deployer,
    log: true,
    proxy: {
      proxyContract: 'UUPS',
      upgradeIndex: 0,
      execute: {
        init: {
          methodName: 'initialize',
          args: [
            DSP,
            MACH,
            config.exchangeRatio,
            config.maturity,
            config.bonusPeriod,
            config.minDeposit,
            config.manager
          ]
        }
      }
    }
  })
}

// already deployed in testnet, mainnet
deployFn.tags = ["testnet", "mainnet", "Migrator"]

export default deployFn
