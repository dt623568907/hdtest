const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

module.exports = async function({getNamedAccounts, deployments}){
    const {save} = deployments;
    const {deployer} = await getNamedAccounts();
    console.log("部署用户地址:", deployer);

    //读取地址文件
    const storePath = path.resolve(__dirname,"./.cache/proxyNFTAuction.json");
    const storeData = fs.readFileSync(storePath, "utf-8");
    const { proxyAddress, implAddress, abi } = JSON.parse(storeData);
    console.log("代理地址:", proxyAddress);

    //升级版业务合约
    const NFTAuctionV2 = await ethers.getContractFactory("NFTAuctionV2");

    // console.log("signer:", NFTAuctionV2.signer);

    //升级业务合约
    await NFTAuctionV2.deployed;
    const NFTAuctionProxyV2 = await upgrades.upgradeProxy(proxyAddress ,NFTAuctionV2);
    await NFTAuctionProxyV2.deployed();
    const proxyAddressV2 = await upgrades.erc1967.getImplementationAddress(NFTAuctionProxyV2);

    console.log("新代理地址:", proxyAddressV2);

    await save("NFTAuctionProxyV2",{
        abi,
        address: proxyAddressV2
    })

}

exports.tags = ["upgradeNFTAuction"] 