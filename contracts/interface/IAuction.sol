// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 导入OpenZeppelin的NFT和代币标准接口
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IAuction
 * @dev 拍卖基础接口
 */
interface IAuction {
    /**
     * @dev 拍卖状态枚举
     */
    enum AuctionStatus {
        Active,     // 拍卖进行中
        Completed   // 拍卖已完成
    }

    /**
     * @dev 拍卖信息结构体
     * 存储拍卖的所有关键信息
     */
    struct AuctionInfo {
        address nftAddress;             // 待拍卖NFT的合约地址
        uint256 tokenId;                // 待拍卖NFT的代币ID
        address seller;                 // 拍卖者地址
        uint256 startPrice;             // 起拍价（单位：对应支付代币最小单位）
        uint256 startTime;              // 拍卖开始时间戳
        uint256 endTime;                // 拍卖结束时间戳
        address paymentTokenAddress;    // 支付代币地址（address(0)表示ETH）    
        AuctionStatus status;           // 拍卖状态（IAuction.AuctionStatus枚举类型）
        uint256 highestBid;             // 最高出价金额（单位：对应支付代币最小单位）
        address highestBidder;          // 最高出价人地址
        Bid[] bidHistory;               // 出价历史列表（存储所有有效出价记录，Bid来自IAuction接口）
    }

    // 出价单结构体
    struct Bid {
        address bidder;         // 出价人地址
        uint256 amount;         // 出价金额
        uint256 timestamp;      // 出价时间戳
        bool isERC20;           // 是否使用ERC20代币出价
        address erc20Address;   // ERC20代币地址（如果使用ERC20出价）
    }

    // 拍卖创建事件
    event AuctionCreated(
        uint256 indexed auctionId,       // 拍卖ID
        address indexed nftContract,     // NFT合约地址
        uint256 indexed tokenId,         // NFT代币ID
        address seller,                  // 拍卖者地址
        uint256 startTime,               // 拍卖开始时间戳
        uint256 endTime                  // 拍卖结束时间戳
    );
    // 出价事件
    event BidPlaced(
        uint256 indexed auctionId,       // 拍卖ID
        address indexed bidder,          // 出价人地址
        uint256 amount,                  // 出价金额
        address erc20Address             // ERC20代币地址（如果是0,则表示ETH）
    );
    /**
     * 拍卖结束事件：
     * @param auctionId 拍卖ID； 
     * @param winnerAddress  赢家地址；
     * @param winningBidAmount 赢家最终出价金额；
     * @param paymentTokenAddress 支付代币地址（address(0)表示ETH）；   
     */
    event AuctionEnded(
        uint256 indexed auctionId,          // 拍卖ID
        address indexed winnerAddress,      // 赢家地址
        uint256 winningBidAmount,           // 赢家最终出价金额
        address paymentTokenAddress         // 支付代币地址（address(0)表示ETH）    
    );

    /**
     * 创建拍卖；
     * @param auctionId 拍卖ID；（需由调用者确保唯一性）
     * @param nftAddress NFT合约地址；
     * @param tokenId NFT代币ID；   
     * @param startPrice 起拍价；（单位：wei或代币最小单位）
     * @param startTime 拍卖开始时间戳；（需大于当前时间）
     * @param endTime 拍卖结束时间戳；（需大于startTime）
     * @param paymentTokenAddress 支付代币地址（address(0)表示ETH）； 
     */
    function createAuction(
        uint256 auctionId,          // 拍卖ID
        address nftAddress,         // NFT合约地址
        uint256 tokenId,            // NFT代币ID
        uint256 startPrice,         // 起拍价
        uint256 startTime,          // 拍卖开始时间戳
        uint256 endTime,            // 拍卖结束时间戳
        address paymentTokenAddress
    ) external;

    /**
     * @dev 出价
     * 用户参与拍卖的出价功能
     * @param auctionId 拍卖ID
     * @param amount 出价金额
     */
    function placeBid(uint256 auctionId, uint256 amount) external payable;

    /**
     * @dev 结束拍卖
     * 在拍卖结束时结算拍卖，分配NFT和支付款项
     */
    function endAuction(uint256 auctionId) external;

    /**
     * @dev 获取工厂地址
     * 返回创建该拍卖的工厂合约地址
     * @return 工厂合约地址
     */
    function factory() external view returns (address);
}