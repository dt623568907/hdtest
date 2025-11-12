require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades");
require("solidity-coverage");
require("dotenv").config(); // 加载 .env 文件中的环境变量

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  namedAccounts:{
    deployer:0,
    user1:1,
    user2:2,
  },
  networks: {
    // Sepolia 测试网
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`, // Infura 节点 URL
      accounts: [process.env.PRIVATE_KEY], // 部署合约的账户私钥（从 .env 读取）
      chainId: 11155111 // Sepolia测试网唯一链ID（用于Hardhat识别网络）
    },
  },
  coverage: {
    // 排除不需要计算覆盖率的文件（支持 glob 模式）
    exclude: ["contracts/mocks/**/*"], 
    // 自定义报告格式（默认生成 lcov、text、clover 格式）
    reporter: ["lcov", "text-summary"],
    // 测试命令超时时间（毫秒，默认 300000）
    timeout: 500000,
    // 是否在测试前自动运行 hardhat clean（默认 true）
    clean: true,
    // 额外的编译器选项
    compilerOpts: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
