// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract test{
    uint256 public account;

    event success(uint256 indexed count);

    constructor(){
        account = 1;
    }

    function increase(uint256 amount) public {
        account += amount;
        emit success(account);
    }
}
