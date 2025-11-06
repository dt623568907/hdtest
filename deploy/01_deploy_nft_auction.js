
const { deployments, upgrades } = require("hardhat");

const fs = require("fs");
const path = require("path");

module.exports = async({ getNamedAccounts, deployments, ethers })=>{
    const {save} = deployments;
    const {deployer} = await getNamedAccounts();

    console.log("部署用户地址:", deployer);
    const NFTAuction = await ethers.getContractFactory("NFTAuction");

    //通过代理合约部署
    const nftAuctionProxy = await upgrades.deployProxy(NFTAuction, [], {
        initializer: "initialize",
        kind: "uups"
    })

    await nftAuctionProxy.deployed();
    const proxyAddress =  await nftAuctionProxy.address;
    console.log("代理合约地址:",proxyAddress);
    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log("实现合约地址:", implAddress);


    const storePath = path.resolve(__dirname, "./.cache/proxyNFTAuction.json");

    await fs.writeFileSync(
        storePath,
        JSON.stringify({
        proxyAddress,
        implAddress,
        abi: NFTAuction.interface.format("json")
    }));

    await save("NFTAuctionProxy",{
        abi: NFTAuction.interface.format("json"),
        address: proxyAddress,
        // args:[],
        // log:true,
    })
}



module.exports.tags = ["deployNftAuction"];