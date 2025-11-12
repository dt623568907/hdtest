// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./AuctionFactory.sol";

contract AuctionFactoryV2 is AuctionFactory {

    function initializeV2() external initializer {
        super.__Ownable_init(msg.sender);
    }
    function _authorizeUpgrade(address newImplementation) internal virtual override(AuctionFactory) onlyOwner {}

    function testHello() external pure returns (string memory){
        return "Hello World";
    }
}
