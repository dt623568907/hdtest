const { expect } = require("chai");
const { experiment } = require("fp-ts/lib/Store");
const hre = require("hardhat");

describe("MyToken Test", async()=>{

    // const { ethers } = hre;

    // const initialSupply = 10000;

    // let MyTokenContract;

    // let account1, account2;

    // beforeEach(async()=>{

    //     [account1, account2] = await ethers.getSigners();
        
    //     const MyToken = await ethers.getContractFactory("MyToken");

    //     MyTokenContract = await MyToken.connect(account2).deploy(initialSupply);

    //     await MyTokenContract.deployed();

    //     const contractAddress = await MyTokenContract.getAddress();

    //     console.log(contractAddress);

    //     // expect(contractAddress).to.length.greaterThan(0);

    // });

    // it("验证下合约的name,symbol,decmial",async()=>{

    //     const name = await MyTokenContract.name();

    //     const symbol = await MyTokenContract.symbol();

    //     const decmials = await MyTokenContract.decimals();

    //     expect(name).to.equal("MyToken");

    //     expect(symbol).to.equal("MTK");
        
    //     expect(decmials).to.equal(18);
    //     console.log(decmials);
    // })

    // it("测试转账",async()=>{
    //     // const balanceOfAccount1 = await MyTokenContract.balanceOf(account1);

    //     // expect(balanceOfAccount1).to.equal(initialSupply);

    //     const resp = await MyTokenContract.transfer(account1, initialSupply/2);

    //     console.log(resp);
         
    //     const balanceOfAccount2 = await MyTokenContract.balanceOf(account2);

    //     expect(balanceOfAccount2).to.equal(initialSupply / 2);

    // })
})