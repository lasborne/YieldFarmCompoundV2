require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config()

const ethereum_mainnet = process.env.ETH_MAINNET_API_KEY
const goerli_testnet = process.env.GOERLI_TESTNET_API_KEY
const deployerPrivateKey = process.env.PRIVATE_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "goerli",
  networks: {
    hardhat: {},
    goerli: {
      url: goerli_testnet,
      accounts: [deployerPrivateKey]
    },
    ethereum: {
      url: ethereum_mainnet,
      accounts: [deployerPrivateKey]
    }
  },
  /*etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },*/
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}
