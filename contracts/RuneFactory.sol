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
    struct Token {
        string name;
        string symbol;
        uint256 initialSupply;
        address initialOwner;
        uint256 runeIDBTC;
    }
    Token[] public tokens;
    
    function createRune(string memory name, string memory symbol, uint256 initialSupply, address initialOwner, uint256 runeIDBTC) public {
        Rune newToken = new Rune(name, symbol, initialSupply, initialOwner);
        tokens.push(Token(name, symbol, initialSupply, initialOwner, runeIDBTC));
        emit TokenCreated(address(newToken));
    }
}
