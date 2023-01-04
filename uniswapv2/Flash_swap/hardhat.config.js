require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('dotenv').config();
 

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
        forking: {
            url: `https://eth-mainnet.alchemyapi.io/v2/j2O_DBJcuONCj6y8jbKxGR2inJiVdGjs`,
            blockNumber: 14638929,
        },
    },
},
};