// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.6.0/contracts/token/ERC20/ERC20.sol";

contract MyFungibleToken is ERC20 {
    constructor(uint256 _initalSuppy) ERC20("MyFungibleToken", "MFT") {
        _mint(msg.sender, _initalSuppy);
    }

    function mintToken(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }
}
