# NFT 拍卖市场项目

本项目是一个基于以太坊区块链的 NFT 拍卖市场，支持 NFT 的创建、拍卖、出价和结算等核心功能。项目采用 Hardhat 开发框架，结合 OpenZeppelin 合约库，实现了安全可靠的 NFT 拍卖机制。

## 项目结构

```
hdtest/
├── contracts/                      # 智能合约源代码
│   ├── Auction.sol                 # 拍卖合约
│   ├── AuctionFactory.sol          # 拍卖工厂合约
│   ├── AuctionFactoryV2.sol        # 拍卖工厂合约V2版本
│   ├── AuctionV2.sol               # 拍卖合约V2版本
│   ├── interface/                  # 接口合约
│   │   └── IAuction.sol            # 拍卖接口
│   ├── oracles/                    # 预言机
│   │   └── PriceConverter.sol      # 价格转换合约
│   └── tokens/                     # 代币
│       ├── TestERC20.sol           # 测试ERC20代币
│       └── TestERC721.sol          # 测试ERC721代币
├── deploy/                         # 部署脚本
│   └── 01_deploy_auction_factory.js # 拍卖工厂部署脚本
├── test/                           # 测试文件
│   ├── auction_complete_test.js    # 完整拍卖流程测试
│   └── upgrade_auction_test.js     # 拍卖合约升级测试
├── hardhat.config.js               # Hardhat配置文件
├── package.json                    # 项目依赖配置
└── .env                            # 环境变量（不纳入版本控制）
```

## 核心功能说明

### NFT 管理
- 支持 NFT 的铸造
- 实现 NFT 元数据管理

### 拍卖功能
- 创建拍卖（设置起拍价、拍卖时长）
- 拍卖出价（支持多次出价，自动更新最高价）
- 拍卖结算（结束后自动转移 NFT 和资金）

### 拍卖工厂
- 统一管理拍卖合约
- 简化拍卖创建流程

### 合约升级
- 支持拍卖合约和工厂合约的无缝升级
- 保留现有数据和状态

## 环境准备

### 前置依赖
- Node.js (v14+)
- npm 或 yarn
- Hardhat

### 环境变量配置
创建`.env`文件，添加以下环境变量：
```
INFURA_API_KEY=.......
PRIVATE_KEY=.......
ETHERSCAN_API_KEY=.......
```

## 部署步骤

### 1. 项目初始化
```bash
# 初始化 npm 项目
npm init -y

# 安装 Hardhat 核心包
npm install --save-dev "hardhat@^2.17.0"

# 初始化 Hardhat 项目
npx hardhat init
```

### 2. 安装依赖包
```bash
# 安装 Hardhat 工具包
npm install --save-dev @nomiclabs/hardhat-waffle@2.0.6 ethereum-waffle@3.4.4 chai@4.3.7 @nomiclabs/hardhat-ethers@2.2.3 ethers@5.7.2

# 安装部署管理工具
npm install --save-dev hardhat-deploy

# 安装合约验证插件
npm install --save-dev @nomiclabs/hardhat-etherscan

# 安装环境变量管理工具
npm install --save-dev dotenv

# 安装代码格式化工具
npm install --save-dev prettier prettier-plugin-solidity

# 安装预言机
npm install @chainlink/contracts

# 安装合约升级相关依赖
npm install @openzeppelin/contracts-upgradeable

# 安装基础合约相关依赖
npm install @openzeppelin/contracts

# 安装测试断言工具
npm install --save-dev chai @nomicfoundation/hardhat-chai-matchers

# 安装覆盖率测试工具
npm install --save-dev solidity-coverage
```

### 3. 编译合约
```bash
npx hardhat compile
```

### 4. 运行测试
```bash
npx hardhat test

# 运行覆盖率测试
npx hardhat coverage
```

### 5. 部署合约
```bash
# 部署到本地网络
npx hardhat node
npx hardhat deploy --network localhost

# 部署到测试网
npx hardhat deploy --network sepolia
```

## 测试功能说明

### 完整拍卖流程测试
- 验证合约部署
- 创建拍卖
- 执行出价
- 结束拍卖
- 验证资产转移

### 合约升级测试
- 验证合约可升级性
- 测试升级后新功能
- 确保升级后数据一致性

## 安全注意事项

1. 在部署到主网前，请进行全面的安全审计
2. 私钥和API密钥应妥善保管在`.env`文件中，不要提交到版本控制
3. 合约升级时需谨慎，确保新合约与旧合约兼容
4. 建议在测试网充分测试后再部署到主网

## 许可证

MIT License
