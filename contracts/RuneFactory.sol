// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rune is ERC20, Ownable {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address initialOwner) 
        ERC20(name, symbol)
        Ownable(initialOwner) {
        _mint(initialOwner, initialSupply);
    }
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
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

    function getTokenCount() public view returns (uint256) {
        return tokens.length;
    }

    function getToken(uint256 index) public view returns (Token memory) {
        return tokens[index];
    }

    function getTokens() public view returns (Token[] memory) {
        return tokens;
    }

    function getTokenAddress(string memory name, string memory symbol, uint256 initialSupply, address initialOwner, bytes32 salt) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(Rune).creationCode,
            abi.encode(name, symbol, initialSupply, initialOwner)
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint(hash)));
    }

    function createRune(string memory name, string memory symbol, uint256 initialSupply, address initialOwner, uint256 runeIDBTC, bytes32 salt) public {
        address predictedAddress = getTokenAddress(name, symbol, initialSupply, initialOwner, salt);
        Rune newToken = new Rune{salt: salt}(name, symbol, initialSupply, initialOwner);
        require(address(newToken) == predictedAddress, "Address prediction failed");
        tokens.push(Token(name, symbol, initialSupply, initialOwner, runeIDBTC));
        emit TokenCreated(address(newToken));
    }
}
