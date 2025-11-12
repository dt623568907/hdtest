// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./interface/IAuction.sol";
import "hardhat/console.sol";
import "./oracles/PriceConverter.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
using PriceConverter for uint256;

contract Auction is IAuction, Initializable, ReentrancyGuardUpgradeable, UUPSUpgradeable, IERC721Receiver {

    /// @notice 拍卖ID到拍卖信息的映射 ==> 通过ID快速查询拍卖详情
    mapping(uint256 => AuctionInfo) public auctions;

    /// @notice 拍卖计数器 ==> 记录已创建的拍卖总数
    uint256 public auctionCount;

    /// @notice 存储工厂地址
    address public auctionFactory;

    /**
     * @dev 获取工厂地址
     * 返回创建该拍卖的工厂合约地址
     * @return 工厂合约地址
     */
    function factory() external view returns (address) {
        return auctionFactory;
    }

    // 代币预言机映射
    mapping(address => address) public tokenPriceFeeds;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev 初始化函数
     * @param _auctionFactory 工厂合约地址
     */
    function initialize(address _auctionFactory) public initializer {
        // 调用父类初始化函数
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        
        // 存储工厂地址
        auctionFactory = _auctionFactory; 
        // 初始化价格预言机映射
        initTokenPriceFeeds();
    }

    // 初始化价格预言机映射
    function initTokenPriceFeeds() internal {
        // Chainlink ETH/USD价格预言机地址
        address ETH_USD_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        // Chainlink USDC/USD价格预言机地址
        address USDC_USD_PRICE_FEED = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;

        // 为ETH设置价格源（用address(0)代表ETH）
        tokenPriceFeeds[address(0)] = ETH_USD_PRICE_FEED; // ETH
        // 为Sepolia测试网上的USDC代币设置价格源（地址为测试网USDC合约地址）
        tokenPriceFeeds[0x514910771AF9Ca656af840dff83E8264EcF986CA] = USDC_USD_PRICE_FEED; // USDC
    }
    
    // 添加receive函数以允许合约接收ETH
    receive() external payable {
        // 仅记录日志，不需要额外逻辑
    }

    //创建拍卖
    function createAuction(
        uint256 auctionId,          // 拍卖ID
        address nftAddress,         // NFT合约地址
        uint256 tokenId,            // NFT代币ID
        uint256 startPrice,         // 起拍价
        uint256 startTime,          // 拍卖开始时间戳
        uint256 endTime,            // 拍卖结束时间戳
        address paymentTokenAddress
    ) external{
        require(auctions[auctionId].seller == address(0), "Auction ID already exists");
        //检查参数
        require(endTime > startTime, "Invalid auction duration");
        require(startPrice > 0, "Start price must be greater than 0");
        

        // 创建拍卖信息结构体对象
        AuctionInfo storage auctionInfo = auctions[auctionId];
        auctionInfo.nftAddress = nftAddress;                      // 待拍卖NFT的合约地址
        auctionInfo.tokenId = tokenId;                            // 待拍卖NFT的合约地址
        auctionInfo.seller = msg.sender;                          // 拍卖者地址
        auctionInfo.startPrice = startPrice;                      // 起拍价（单位：对应支付代币最小单位）
        auctionInfo.startTime = startTime;                        // 拍卖开始时间戳
        auctionInfo.endTime = endTime;                            // 拍卖结束时间戳
        auctionInfo.paymentTokenAddress = paymentTokenAddress;    // 支付代币地址（address(0)表示ETH）
        auctionInfo.status = AuctionStatus.Active;                // 拍卖状态（IAuction.AuctionStatus枚举类型）
        auctionInfo.highestBid = 0;                               // 最高出价金额（单位：对应支付代币最小单位）
        auctionInfo.highestBidder = address(0);                   // 最高出价人地址

        // 拍卖计数器自增（更新总拍卖数）
        auctionCount++;

        // 触发AuctionCreated事件（来自IAuction接口），记录拍卖创建信息
        emit AuctionCreated(auctionId, nftAddress, tokenId, msg.sender, startTime, endTime);
    }

        /**
     * @dev 出价
     * 用户参与拍卖的出价功能
     * @param auctionId 拍卖ID
     * @param amount 出价金额
     */
    function placeBid(uint256 auctionId, uint256 amount) external payable nonReentrant {
        // 确保发送的ETH金额与出价金额一致
        require(msg.value == amount, "Sent ETH does not match bid amount");
        // 引用拍卖信息（storage修饰符：直接操作原数据，避免拷贝）
        AuctionInfo storage auction = auctions[auctionId];

        require(auction.status == AuctionStatus.Active, "Auction is not active");
        require(block.timestamp >= auction.startTime, "Auction has not started");
        require(block.timestamp <= auction.endTime, "Auction has ended");
        require(amount > auction.startPrice, "Bid below start price");
        require(amount > auction.highestBid, "Bid below current highest bid");

        bool isETH = true;//测试比价使用
        // bool isETH = auction.paymentTokenAddress == address(0);
        // uint8 decimals = isETH ? 18 : IERC20(auction.paymentTokenAddress).decimals(); //生产环境用

        //计算出最高金额折合成美元的金额
        // uint256 amountInUSD = PriceConverter.convertToUSD(amount, decimals, _getTokenFeed(isETH ? address(0) : auction.paymentTokenAddress));
        uint256 amountInUSD = isETH ? 1000 * amount : 20000 * amount; //本地测试环境使用，实际环境中需要从预言机获取价格

         // 计算出最高出价金额折合的美元价值
        // uint256 highestBidUSD = auction.highestBid > 0 ? PriceConverter.convertToUSD(auction.highestBid, decimals, _getTokenFeed(isETH ? address(0) : auction.paymentTokenAddress)) : 0;
        uint256 highestBidUSD = auction.highestBid > 0 ? (isETH ? 1000 * auction.highestBid : 20000 * auction.highestBid) : 0; //本地测试环境使用，实际环境中需要从预言机获取价格

        // 出价金额需大于当前最高出价金额
        require(amountInUSD > highestBidUSD, "Bid below current highest bid in USD");
        
        // 保存旧的最高出价者地址，用于后续退款
        address previousHighestBidder = auction.highestBidder;
        uint256 previousHighestBid = auction.highestBid;

        // 更新此拍卖单出价信息
        auction.highestBid = amount;
        auction.highestBidder = msg.sender;

        // 记录本次出价到历史列表
        auction.bidHistory.push(
            Bid(
                msg.sender, // bidder
                amount,     // amount
                block.timestamp, // timestamp
                !isETH,     // isERC20
                auction.paymentTokenAddress // tokenAddress
            )
        );

        // 退还前一个最高价
        if(previousHighestBidder != address(0) ){
            // 直接退款给前一个最高出价者
            payable(previousHighestBidder).transfer(previousHighestBid);
        }

        // 触发出价事件
        emit BidPlaced(auctionId, msg.sender, amount, auction.paymentTokenAddress);
    }

    function _refundPreviousBidder(AuctionInfo storage auction) internal {
        Bid storage lastAuctionBid = auction.bidHistory[auction.bidHistory.length - 1];
        address bidder = lastAuctionBid.bidder;
        uint256 amount = lastAuctionBid.amount;
        address erc20Address = lastAuctionBid.erc20Address;

        // 根据出价类型（ERC20/ETH）执行退款
        if(lastAuctionBid.isERC20){
            // ERC20代币出价，需要调用代币合约的transfer函数，将代币退回给前一个最高价出价人
            IERC20(erc20Address).transfer(bidder, amount);
        } else {
            // ETH出价，直接调用transfer函数，将ETH退回给前一个最高价出价人
            payable(bidder).transfer(amount);
        }
    }

    /**
     * @dev 内部函数：获取代币的预言机地址
     * @param token 目标代币地址（address(0)代表ETH）
     * @return 预言机地址（若工厂也无配置则revert）
     */
    function _getTokenFeed(address token) internal view returns (address) {

        address feed = tokenPriceFeeds[token];
        require(feed != address(0), "Factory has no feed for token");
        
        return feed;
    }

    /**
     * 结束拍卖
     * 通常由卖家主动调用，或时间到期等待调用；
     * @param auctionId 拍卖ID；
     */
    function endAuction(uint256 auctionId) external nonReentrant{
        AuctionInfo storage auction = auctions[auctionId];

        // 校验：拍卖状态必须为"进行中"
        require(auction.status == AuctionStatus.Active, "Auction is not active");

        // 校验：当拍卖已过期时，任何人都可以结束拍卖
        // 如果拍卖未过期（但状态仍为Active），则只有卖家可以主动结束
        if (block.timestamp < auction.endTime) {
            require(msg.sender == auction.seller, "Only seller can end active auction");
        }

        // 更新拍卖状态为"已结束"
        auction.status = AuctionStatus.Completed;

        if (auction.highestBidder != address(0)) {
            // 根据支付类型，将资金分别转移给卖家和平台
            if(auction.paymentTokenAddress == address(0)){
                // 检查合约余额是否足够
                require(address(this).balance >= auction.highestBid, "Insufficient contract balance");
                
                payable(auction.highestBidder).transfer(auction.highestBid);
            }else{
                // ERC20支付：调用代币合约的transfer函数转移给卖家
                require(IERC20(auction.paymentTokenAddress).transfer(auction.seller, auction.highestBid), "ERC20 transfer failed");
            }

            // 将NFT转移给最高出价者（获胜者）
            IERC721(auction.nftAddress).transferFrom(
                address(this),              // 转出地址：拍卖合约
                auction.highestBidder,      // 转入地址：最高出价者
                auction.tokenId);

        }else{
            // 无最高出价者（拍卖流拍），将NFT退回给卖家
            IERC721(auction.nftAddress).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId
            );
        }
        
        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid, auction.paymentTokenAddress);
    }

     /**
     *  获取拍卖详情；
     * @param auctionId 拍卖ID； 
     * @return nftAddress NFT合约地址；
     * @return tokenId NFT代币ID；   
     * @return seller 拍卖者地址； 
     * @return startPrice 起拍价；（单位：wei或代币最小单位）
     * @return startTime 拍卖开始时间戳；（需大于当前时间）
     * @return endTime 拍卖结束时间戳；（需大于startTime）  
     * @return paymentTokenAddress 支付代币地址（address(0)表示ETH）； 
     * @return status 拍卖状态； 
     * @return highestBid 最高出价金额；（单位：wei或代币最小单位） 
     * @return highestBidder 最高出价人地址；
     */
    function getAuctionDetails(uint256 auctionId) external view returns (
        address nftAddress,             // NFT合约地址
        uint256 tokenId,                // NFT代币ID
        address seller,                 // 拍卖者地址 
        uint256 startPrice,             // 起拍价
        uint256 startTime,              // 拍卖开始时间戳 
        uint256 endTime,                // 拍卖结束时间戳
        address paymentTokenAddress,    // 支付代币地址（address(0)表示ETH）
        AuctionStatus status,           // 拍卖状态 
        uint256 highestBid,             // 最高出价金额 （单位：wei或代币最小单位） 
        address highestBidder           // 最高出价人地址
    ){
        require(auctionId > 0, "Invalid auction ID");
        AuctionInfo storage auction = auctions[auctionId];
        return (
            auction.nftAddress,
            auction.tokenId,
            auction.seller,
            auction.startPrice,
            auction.startTime,
            auction.endTime,
            auction.paymentTokenAddress,
            auction.status,
            auction.highestBid,
            auction.highestBidder
        );
    }

    // 接收NFT
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    /**
     * @dev 授权升级函数（UUPS代理模式必需）
     * 只允许工厂合约进行升级
     */
    function _authorizeUpgrade(address newImplementation) internal view override {
        require(msg.sender == auctionFactory, "Only auction factory can upgrade");
        newImplementation = newImplementation;
    }
}