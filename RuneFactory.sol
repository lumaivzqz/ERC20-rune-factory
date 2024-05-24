// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rune is ERC20, Ownable {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address initialOwner) 
        ERC20(name, symbol)
        Ownable(initialOwner) {
        _mint(msg.sender, initialSupply);
    }
}

contract RuneFactory {
    event TokenCreated(address tokenAddress);
    
    function createRune(string memory name, string memory symbol, uint256 initialSupply, address initialOwner) public {
        MyERC20Token newToken = new MyERC20Token(name, symbol, initialSupply, initialOwner);
        emit TokenCreated(address(newToken));
    }
}
