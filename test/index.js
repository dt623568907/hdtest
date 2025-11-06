const { log } = require("fp-ts/lib/Console")
const {ethers, deployments, upgrades} = require("hardhat")
const {expert} = require("chai")

describe("Starting", async function(){
    // it("Should be able to deploy", async function(){
    //     const Contract = await ethers.getContractFactory("NFTAuction")
    //     const contract = await Contract.deploy()
    //     await contract.deployed()

    //     await contract.createAuction(
    //         100 * 1000,
    //         ethers.parseEther("0.0000000001"),
    //         ethers.ZeroAddress,
    //         1
    //     )

    //     const auction = await contract.auction(0)

    //     console.log(auction)
    // })

    it("test upgrade", async function(){
        //部署业务合约
        await deployments.fixture(["deployNFTAuction"]);

        const nftAuctionProxy = await deployments.get("NFTAuctionProxy");
        
        //调用creatAuction 方法拍卖
        const nftAuction = await ethers.getContractAt("NFTAuction", nftAuctionProxy.address);
        await nftAuction.creatAuction(
            100 * 1000,
            ethers.parseEther("0.01"),
            ethers.ZeroAddress,
            1
        );
        const auction = await nftAuction.auctions(0)
        console.log("创建拍卖成功", auction);

        const implAddress1 = await upgrades.erc1967.getImplementationAddress(
            nftAuctionProxy.address
        );
        //升级合约
        await deployments.fixture(["upgradeNFTAuction"]);
        const implAddress2 = await upgrades.erc1967.getImplementationAddress(
            nftAuctionProxy.address
        );


        //读取合约的auction[0]
        const auctions2 = await nftAuction.auctions(0);
        console.log("升级后读取拍卖成功::", auctions2);

        console.log("implAddress1:", implAddress1, "/nimplAddress2:", implAddress2);

        const nftAuctionV2 = await ethers.getContractAt("NFTAuctionV2", nftAuctionProxy.address);
        const hello = await nftAuction.testhello();
        console.log("hello:", hello)

        expert(auctions2.startTime).to.equal(auction.startTime);
        
    })
})