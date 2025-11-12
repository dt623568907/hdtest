// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interface/IAuction.sol";
import "./Auction.sol";
import "./oracles/PriceConverter.sol";
import "hardhat/console.sol";

/**
 * @title AuctionFactory
 * @dev 拍卖工厂合约，支持创建和管理拍卖
 * 为拍卖提供价格预言机服务
 */
contract AuctionFactory is UUPSUpgradeable, OwnableUpgradeable {

    // 拍卖ID计数器
    uint256 private auctionIdCounter;

    // 拍卖合约实现地址
    address public auctionImplementation;

    // 拍卖数据
    mapping(uint256 => address) public auctions;

    // 代币预言机映射
    mapping(address => address) public tokenPriceFeeds;


    /**
     * 拍卖创建事件；
     * @dev 当工厂成功创建新拍卖合约时触发
     * @param auctionId 拍卖ID； （索引参数，支持按ID过滤事件）
     * @param auctionAddress 新创建的拍卖合约地址； （索引参数，支持按合约地址过滤）
     * @param seller 拍卖者地址； （索引参数，支持按卖家过滤）
     */
    event AuctionCreated(uint256 indexed auctionId, address indexed auctionAddress, address indexed seller);

    /**
     * 升级合约事件；
     * @dev 当工厂升级拍卖合约的实现逻辑时触发
     * @param newImplementationAddress 新的拍卖合约实现逻辑地址； （索引参数，支持按合约地址过滤）
     */
    event AuctionImplementationUpgraded(address indexed newImplementationAddress);

    /**
     * 代币预言机更新事件；
     * @dev 当管理员新增或更新代币的价格源时触发；
     * @param tokenAddress 代币地址；
     * @param priceFeedAddress 价格预言机地址；
     */
    event TokenPriceFeedSet(address indexed tokenAddress, address priceFeedAddress);

    // 初始化函数
    function initialize(address _auctionImplementation) external initializer virtual{
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        auctionImplementation = _auctionImplementation;
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

    // 设置或更新价格预言机地址
    function setTokenPriceFeed(address tokenAddress, address priceFeedAddress) internal  {
        // 将代币地址映射到对应的价格预言机地址
        tokenPriceFeeds[tokenAddress] = priceFeedAddress;
        // 触发代币预言机更新事件
        emit TokenPriceFeedSet(tokenAddress, priceFeedAddress);
    }

    /**
     * 创建拍卖合约；
     * @dev 由卖家调用，通过工厂生成独立的拍卖合约 
     * @param nftAddress NFT合约地址
     * @param tokenId NFT代币ID
     * @param startPrice 起拍价（单位：对应支付代币的最小单位）
     * @param duration  拍卖持续时间（单位：秒，从创建时开始计算）
     * @param acceptedPaymentTokenAddress 接受的支付代币地址（如果为地址0，则表示接受ETH支付）
     */
    function createAuction(
        address nftAddress,
        uint256 tokenId,
        uint256 startPrice,
        uint256 duration,
        address acceptedPaymentTokenAddress
    ) external returns (uint256 auctionId){
        // 计算拍卖ID,初始值为0，每创建一个拍卖ID加1
        auctionIdCounter++;
        auctionId = auctionIdCounter;

        // 部署拍卖合约代理
        ERC1967Proxy proxy = new ERC1967Proxy(
            auctionImplementation,
            abi.encodeWithSignature(
                "initialize(address)",
                address(this)
            )
        );
        
        // 存储拍卖代理合约地址
        address auctionProxyAddress = address(proxy);
        auctions[auctionId] = auctionProxyAddress;

        IERC721(nftAddress).transferFrom(address(this), auctionProxyAddress, tokenId);

        // 调用拍卖合约的createAuction函数创建拍卖
        IAuction(auctionProxyAddress).createAuction(
            auctionId,
            nftAddress,
            tokenId,
            startPrice,
            block.timestamp,
            block.timestamp + duration,
            acceptedPaymentTokenAddress
        );
        
        // 触发拍卖创建事件
        emit AuctionCreated(auctionId, auctionProxyAddress, msg.sender);
        return auctionId;
    }

    /**
     * 升级拍卖合约实现逻辑；（通常限制为管理员调用）
     * @dev  用于更新拍卖合约的核心逻辑（如修复漏洞或添加新功能），通常配合代理模式实现
     * @param newImplementationAddress 新的拍卖合约实现逻辑地址；
     */
    function upgradeAuctionImplementation(address newImplementationAddress) external {
        require(msg.sender == owner(), "Only owner can upgrade implementation");
        require(newImplementationAddress != address(0), "New implementation address cannot be zero address");

        // 存储新的拍卖合约实现逻辑地址
        auctionImplementation = newImplementationAddress;

        // 触发拍卖合约实现逻辑升级事件
        emit AuctionImplementationUpgraded(newImplementationAddress);
    }

    /**
     * 根据代币地址查询对应的价格预言机地址；
     * @param token 代币地址；
     */
    function getTokenFeed(address token) external view returns (address){
        return tokenPriceFeeds[token];
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override {
        require(msg.sender == owner(), "Unauthorized: not the owner");
    }
}
