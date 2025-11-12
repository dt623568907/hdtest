const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");

describe("完整拍卖流程测试", function() {
  let owner, seller, bidder1, bidder2, bidder3;
  let auctionImplementation, nftContract, AuctionFactoryProxyAddress, AuctionFactoryProxy;
  let auctionProxyAddress, auctionContract, auctionId;

  // 在测试开始前只执行一次
  before(async function() {
    // 获取账户
    [owner, seller, bidder1, bidder2, bidder3] = await ethers.getSigners();
    
    // 部署 Auction 实现合约
    const Auction = await ethers.getContractFactory("Auction");
    auctionImplementation = await Auction.deploy();
    await auctionImplementation.waitForDeployment();
    
    // 部署 AuctionFactory 工厂合约 (使用 UUPS 代理)
    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    AuctionFactoryProxy = await upgrades.deployProxy(
      AuctionFactory,
      [await auctionImplementation.getAddress()],
      { 
        kind: 'uups',
      }
    );
    await AuctionFactoryProxy.waitForDeployment();

    // 获取工厂代理合约地址
    AuctionFactoryProxyAddress = await AuctionFactoryProxy.getAddress();

    // 部署 TestERC721 NFT 合约
    const TestERC721 = await ethers.getContractFactory("TestERC721");
    nftContract = await TestERC721.deploy();
    await nftContract.waitForDeployment();
    
    // 铸造NFT给卖家
    await nftContract.connect(owner).mint(seller.address, 1);
    console.log("部署完成");
  });

    it("验证合约已正确部署", async function() {
      console.log("Auction Implementation Address:", await auctionImplementation.getAddress());
      console.log("Auction Factory Proxy Address:", await AuctionFactoryProxy.getAddress());
      console.log("TestERC721 Address:", await nftContract.getAddress());
    
      // 验证所有合约都已部署成功
      expect(await auctionImplementation.getAddress()).to.not.be.undefined;
      
      expect(await AuctionFactoryProxy.getAddress()).to.not.be.undefined;
      
      expect(await nftContract.getAddress()).to.not.be.undefined;
    });

    it("验证NFT已正确铸造给卖家", async function() {
      // 验证卖家是否拥有NFT
      const ownerOf = await nftContract.ownerOf(1);
      console.log("NFT 1 Owner:", ownerOf);
      expect(ownerOf).to.equal(seller.address);
    });

    it("是否成功创建拍卖", async function() {
      const nftAddress = await nftContract.getAddress();

      // 直接执行授权和转移，确保NFT在拍卖合约中
      await nftContract.connect(seller).approve(AuctionFactoryProxyAddress, 1);
      console.log("已授权NFT给拍卖合约");

      // 然后转移NFT
      await nftContract.connect(seller).transferFrom(seller.address, AuctionFactoryProxyAddress, 1);
      console.log("已将NFT转移给拍卖合约");

      // 通过工厂代理合约创建拍卖
      const tx = await AuctionFactoryProxy.connect(seller).createAuction(
        nftAddress,
        1,
        ethers.parseEther("0.1"),
        86400, // 24小时持续时间
        ethers.ZeroAddress // 使用0地址表示接受ETH支付
      );
      const receipt = await tx.wait();
      console.log("Create Auction Transaction Receipt Status:", receipt.status);
      
      // 验证交易成功
      expect(receipt.status).to.equal(1);
      
      // 从事件中获取auctionId
      auctionId = receipt.status;
      console.log("拍卖ID:", auctionId);
    });
  
    it("获取拍卖合约地址", async function() {
      // 使用工厂合约获取拍卖合约地址
      auctionProxyAddress = await AuctionFactoryProxy.auctions(auctionId);
      
      // 验证拍卖合约地址有效
      expect(auctionProxyAddress).to.not.be.undefined;
    });

    it("将NFT转移给拍卖合约是否成功", async function() {
      // 验证拍卖合约是否拥有NFT
      const newOwner = await nftContract.connect(owner).ownerOf(1);
      
      expect(newOwner).to.equal(auctionProxyAddress);
    });
    
    it("开始出价比较及拍卖完成后验证测试...", async function() {
        
      // 查询拍卖代理合约地址
      auctionProxyAddress = await AuctionFactoryProxy.auctions(auctionId);
      console.log("拍卖代理合约地址:", auctionProxyAddress);
      
      // 确保我们有拍卖合约实例
      console.log("获取拍卖合约实例...");
      auctionContract = await ethers.getContractAt("Auction", auctionProxyAddress);
      
      // 验证NFT是否已转移给拍卖合约
      const ownerAfterTransfer = await nftContract.ownerOf(1);
      console.log("NFT当前所有者:", ownerAfterTransfer);
      console.log("拍卖合约地址:", auctionProxyAddress);
      expect(ownerAfterTransfer).to.equal(auctionProxyAddress);
      
      // 定义出价金额
      const bidder1Amount = ethers.parseEther("0.2");
      const bidder2Amount = ethers.parseEther("0.5");
  
      // 出价者1先出价
      await auctionContract.connect(bidder1).placeBid(auctionId, bidder1Amount, {value: bidder1Amount});
      console.log("出价者1出价成功");
      
      // 出价者2出价更高
      await auctionContract.connect(bidder2).placeBid(auctionId, bidder2Amount, {value: bidder2Amount});
      console.log("出价者2出价成功");
      
      // 获取拍卖详情，验证最高出价
      const initialDetails = await auctionContract.getAuctionDetails(auctionId);
      const highestBid = initialDetails[8];
      const highestBidder = initialDetails[9];
      
      console.log("当前最高出价者地址:", highestBidder);
      console.log("当前最高出价金额:", ethers.formatEther(highestBid), "ETH");
      
      // 验证最高出价
      expect(highestBid).to.equal(bidder2Amount);
      expect(highestBidder).to.equal(bidder2.address);
      
      // 模拟时间流逝，使拍卖过期，这样任何人都可以结束拍卖
      console.log("\n模拟时间流逝，使拍卖过期...");
      await ethers.provider.send("evm_increaseTime", [86500]); // 增加24小时+100秒
      
      console.log("调用endAuction函数...");
      // 由卖家调用endAuction函数
      await auctionContract.connect(seller).endAuction(auctionId);

      console.log("验证NFT和拍卖状态...");
      
      // 2. 检查当前NFT的所有者
      const currentOwner = await nftContract.ownerOf(1);
      console.log("NFT当前所有者:", currentOwner);
      console.log("预期NFT应转移给:", bidder2.address);
      
      // 3. 验证拍卖合约正确记录了最高出价者信息
      const auctionDetails = await auctionContract.getAuctionDetails(auctionId);
      const contractRecordedBidder = auctionDetails[9]; // highestBidder是第10个返回值
      console.log("合约记录的最高出价者:", contractRecordedBidder);
      
    });
});