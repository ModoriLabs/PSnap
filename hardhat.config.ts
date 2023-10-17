import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-foundry";
import * as dotenv from "dotenv";

dotenv.config();
const MAINNET_PRIVATE_KEY = process.env.MAINNET_PRIVATE_KEY;
const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.21",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    mainnet: {
      url: MAINNET_RPC_URL,
      chainId: 1,
      accounts: MAINNET_PRIVATE_KEY !== undefined ? [MAINNET_PRIVATE_KEY] : [],
    },
    sepolia: {
      url: SEPOLIA_RPC_URL,
      chainId: 11155111,
      accounts: SEPOLIA_PRIVATE_KEY !== undefined ? [SEPOLIA_PRIVATE_KEY] : [],
    },
  },
  verify: {
    etherscan: {
      apiKey: ETHERSCAN_API_KEY,
    },
  },
};

export default config;
