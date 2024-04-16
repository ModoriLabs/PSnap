import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-foundry";
import * as dotenv from "dotenv";

dotenv.config();
const MAINNET_PRIVATE_KEY = process.env.MAINNET_PRIVATE_KEY;
const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL;
const AMOY_RPC_URL = process.env.AMOY_RPC_URL;
const AMOY_PRIVATE_KEY = process.env.AMOY_PRIVATE_KEY;
const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL;
const POLYGON_PRIVATE_KEY = process.env.POLYGON_PRIVATE_KEY;
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
      url: MAINNET_RPC_URL !== undefined ? MAINNET_RPC_URL : "",
      chainId: 1,
      accounts: MAINNET_PRIVATE_KEY !== undefined ? [MAINNET_PRIVATE_KEY] : [],
    },
    sepolia: {
      url: SEPOLIA_RPC_URL !== undefined ? SEPOLIA_RPC_URL : "",
      chainId: 11155111,
      accounts: SEPOLIA_PRIVATE_KEY !== undefined ? [SEPOLIA_PRIVATE_KEY] : [],
    },
    amoy: {
      url: AMOY_RPC_URL !== undefined ? AMOY_RPC_URL : "",
      chainId: 80002,
      accounts: AMOY_PRIVATE_KEY !== undefined ? [AMOY_PRIVATE_KEY] : [],
    },
    polygon: {
      url: POLYGON_RPC_URL !== undefined ? POLYGON_RPC_URL : "",
      chainId: 137,
      accounts: POLYGON_PRIVATE_KEY !== undefined ? [POLYGON_PRIVATE_KEY] : [],
      gasPrice: 200000000000, // 200 gwei
    },
  },
  verify: {
    etherscan: {
      apiKey: ETHERSCAN_API_KEY,
    },
  },
};

export default config;
