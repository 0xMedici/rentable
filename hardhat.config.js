require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: false,
        runs: 100
      }
    }
  },
  networks: {
    // mainnet: {
    //   url: '',
    //   accounts: [""],
    // },
    rinkeby: {
      url: '',
      accounts: [""],
    },
    ropsten: {
      url: '',
      accounts: [""],
    }
  },
  etherscan: {
    apiKey: ""
  }
};
