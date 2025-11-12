// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Auction.sol";

/**
 * @title AuctionV2
 * @dev 拍卖合约，支持创建和管理拍卖
 * 测试升级使用
 */
contract AuctionV2 is Auction {

    function testHello() external pure returns (string memory){
        return "Hello World";
    }
}