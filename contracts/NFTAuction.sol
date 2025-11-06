// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NFTAuction is Initializable, UUPSUpgradeable, OwnableUpgradeable {

    struct Auction{
        //卖家
        address seller;
        //开始时间
        uint256 startTime;
        //拍卖持续时间
        uint256 duration;
        //起始价格
        uint256 startPrice;

        //是否结束
        bool ended;
        //最高出价者
        address highestBidder;
        //最高价
        uint256 highestBid;

        //NFT合约地址
        address nftContract;
        //NFT tonkenId
        uint256 tokenId;
    }

    //状态变量
    mapping(uint256 => Auction) public auctions;
    //下一个拍卖ID
    uint256 public nextAuctionId;
    //管理员地址
    address public admin;

    function initialize() public initializer{
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    //创建拍卖
    function creatAuction(uint256 _duration, uint256 _startPrice, address _nftAddress, uint256 _tokenId) public{
        //只有管理员才能创建拍卖
        require(msg.sender == admin, "Only admin can creat auctions");
        //检查参数
        require(_duration > 1000 * 60, "Duration must be greater than 0");
        require(_startPrice > 0, "Start price must be greater than 0");

        auctions[nextAuctionId] = Auction({
            seller: msg.sender,
            startTime: block.timestamp,
            duration: _duration,
            startPrice: _startPrice,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            nftContract: _nftAddress,
            tokenId: _tokenId
        });
        nextAuctionId++;
    }

    //买家参与买单
    function placeBid(uint256 auctionId)external payable{
        Auction storage auction = auctions[auctionId];
        //判断是否结束
        require(!auction.ended && auction.startTime + auction.duration < block.timestamp, "Auction has ended");
        //判断出价是否大于当前最高出价
        require(msg.value > auction.highestBid && msg.value >= auction.startPrice, "Bid must be higher than the current highest bid");
        //退回之前的最高出价者
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        // 只有管理员可以升级合约
    }

}