// UUPS升级验证测试
// 流程：1.部署AuctionFactory → 2.升级为AuctionFactoryV2 → 3.通过工厂升级AuctionV2
const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");

describe("合约升级测试套件", function() {
  let deployer;
  let factoryProxy;
  let factoryProxyAddress;
  let auctionImplAddress;
  let auctionV2ImplAddress;

  before(async function() {
    [deployer] = await ethers.getSigners();
    console.log("=== UUPS合约升级正确流程验证测试 ===");
    console.log(`执行用户: ${deployer.address}`);
  });

  it("步骤1: 部署AuctionFactory.sol（原始工厂合约）", async function() {
    // 部署Auction实现合约作为初始实现
    const Auction = await ethers.getContractFactory("Auction");
    const auctionImpl = await Auction.deploy();
    await auctionImpl.waitForDeployment();
    auctionImplAddress = await auctionImpl.getAddress();
    console.log(`✓ Auction.sol实现合约部署成功: ${auctionImplAddress}`);
    
    // 部署AuctionFactory代理合约
    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    factoryProxy = await upgrades.deployProxy(AuctionFactory, [auctionImplAddress], {
      kind: 'uups',
      initializer: 'initialize'
    });
    await factoryProxy.waitForDeployment();
    factoryProxyAddress = await factoryProxy.getAddress();
    console.log(`✓ AuctionFactory.sol代理合约部署成功: ${factoryProxyAddress}`);
    
    // 验证工厂合约初始化成功
    const storedImplAddress = await factoryProxy.auctionImplementation();
    expect(storedImplAddress).to.equal(auctionImplAddress);
  });

  it("步骤2: 升级为AuctionFactoryV2.sol", async function() {
    // 部署AuctionFactoryV2实现合约
    console.log("部署AuctionFactoryV2.sol实现合约...");
    const AuctionFactoryV2 = await ethers.getContractFactory("AuctionFactoryV2");
    
    // 升级工厂代理合约到V2版本
    console.log("\n升级工厂代理合约到AuctionFactoryV2...");
    const upgradedFactory = await upgrades.upgradeProxy(factoryProxyAddress, AuctionFactoryV2, {
      kind: 'uups',
      initializer: 'initialize'
    });
    await upgradedFactory.waitForDeployment();
    console.log(`✓ 工厂合约升级成功！升级后地址: ${await upgradedFactory.getAddress()}`);
    
    // 连接到升级后的工厂合约
    const factoryV2 = AuctionFactoryV2.attach(factoryProxyAddress);
    
    // 测试工厂合约的testHello函数
    console.log("\n测试工厂合约的testHello函数...");
    const factoryHello = await factoryV2.testHello();
    console.log(`✓ 工厂合约testHello返回值: ${factoryHello}`);
    
    // 使用chai断言验证结果
    expect(factoryHello).to.equal("Hello World", "工厂合约升级验证失败");
    console.log(`✓ 验证结果: ✅ 成功`);
  });

  it("步骤3: 部署AuctionV2.sol并通过工厂升级", async function() {
    // 部署AuctionV2实现合约
    console.log("部署AuctionV2.sol实现合约...");
    const AuctionV2 = await ethers.getContractFactory("AuctionV2");
    const auctionV2Impl = await AuctionV2.deploy();
    await auctionV2Impl.waitForDeployment();
    auctionV2ImplAddress = await auctionV2Impl.getAddress();
    console.log(`✓ AuctionV2.sol实现合约部署成功: ${auctionV2ImplAddress}`);
    
    // 通过工厂合约升级拍卖实现地址
    console.log("\n通过工厂合约升级拍卖实现地址...");
    const AuctionFactoryV2 = await ethers.getContractFactory("AuctionFactoryV2");
    const factoryV2 = AuctionFactoryV2.attach(factoryProxyAddress);
    
    const tx = await factoryV2.upgradeAuctionImplementation(auctionV2ImplAddress);
    await tx.wait();
    console.log(`✓ 拍卖实现地址升级成功！新地址: ${auctionV2ImplAddress}`);
    
    // 验证工厂中的实现地址已更新
    const storedV2ImplAddress = await factoryV2.auctionImplementation();
    expect(storedV2ImplAddress).to.equal(auctionV2ImplAddress, "拍卖实现地址更新失败");
  });

  it("步骤4: 验证升级后的核心功能", async function() {
    // 连接到升级后的拍卖实现合约
    const AuctionV2 = await ethers.getContractFactory("AuctionV2");
    const auctionV2 = AuctionV2.attach(auctionV2ImplAddress);
    
    // 测试AuctionV2合约的testHello函数
    console.log("\n测试AuctionV2合约的testHello函数...");
    const auctionHello = await auctionV2.testHello();
    console.log(`✓ 拍卖合约testHello返回值: ${auctionHello}`);
    
    // 使用chai断言验证结果
    expect(auctionHello).to.equal("Hello World", "拍卖合约升级验证失败");
    console.log(`✓ 验证结果: ✅ 成功`);
    
  });
});