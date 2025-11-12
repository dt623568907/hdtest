const { upgrades } = require("hardhat");

module.exports = async({ getNamedAccounts, ethers })=>{
    const {deployer} = await getNamedAccounts();

    console.log("部署用户地址:", deployer);
    
    // 1. 先部署一个临时的Auction实现合约，作为AuctionFactory初始化的占位符
    const Auction = await ethers.getContractFactory("Auction");
    console.log("部署Auction实现合约...");
    const tempAuctionImpl = await Auction.deploy(deployer);
    await tempAuctionImpl.waitForDeployment();
    const tempAuctionImplAddress = await tempAuctionImpl.target;
    console.log("Auction实现合约地址:", tempAuctionImplAddress);
    
    // 2. 使用UUPS代理模式部署AuctionFactory合约
    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    console.log("部署AuctionFactory代理合约...");
    
    // 通过代理合约部署，使用临时的Auction实现合约地址作为初始化参数
    const factoryProxy = await upgrades.deployProxy(AuctionFactory, [tempAuctionImplAddress], {
        initializer: "initialize",
        kind: "uups"
    });

    await factoryProxy.waitForDeployment();
    const factoryProxyAddress = await factoryProxy.target;
    console.log("AuctionFactory代理合约地址:", factoryProxyAddress);
    
    const factoryImplAddress = await upgrades.erc1967.getImplementationAddress(factoryProxyAddress);
    console.log("AuctionFactory实现合约地址:", factoryImplAddress);
    
    // 3. 现在使用正确的工厂地址部署正式的Auction实现合约
    console.log("部署正式Auction实现合约，使用正确的工厂地址...");
    const auctionImplementation = await Auction.deploy(factoryProxyAddress);
    await auctionImplementation.waitForDeployment();
    const auctionImplAddress = await auctionImplementation.target;
    console.log("正式Auction实现合约地址:", auctionImplAddress);
    
    // 4. 更新AuctionFactory中的Auction实现合约地址
    console.log("更新AuctionFactory中的Auction实现合约地址...");
    await factoryProxy.upgradeAuctionImplementation(auctionImplAddress);
    console.log("Auction实现合约地址更新完成");
    
    console.log("部署完成！");
    console.log("- Auction实现合约地址:", auctionImplAddress);
    console.log("- AuctionFactory代理合约地址:", factoryProxyAddress);
    console.log("- AuctionFactory实现合约地址:", factoryImplAddress);
}

module.exports.tags = ["deployAuctionFactory"];