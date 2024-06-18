// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RuneToken is ERC1155, Ownable {
    struct TokenInfo {
        string uri;
        string name;
        string symbol;
        uint256 maxSupply;
        uint256 currentSupply;
        uint256 defaultMintAmount;
    }

    mapping(uint256 => TokenInfo) private _tokenInfos;
    mapping(address => uint256[]) private _userTokens;

    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {}

    /**
     * @dev Returns the URI for a given token ID
     * @param tokenId ID of the token to query
     * @return URI of the token
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenInfos[tokenId].uri;
    }

    /**
     * @dev Mints a new fungible token
     * @param tokenURI URI of the token
     * @param runeName Unique name of the rune
     * @param name Name of the token
     * @param symbol Symbol of the token
     * @param maxSupply Maximum supply of the token
     * @param initialSupply Initial supply of the token
     * @param defaultMintAmount Default amount to mint each time
     */
    function mintFungible(
        string memory tokenURI,
        string memory runeName,
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 initialSupply,
        uint256 defaultMintAmount
    ) public onlyOwner {
        require(initialSupply <= maxSupply, "Initial supply exceeds max supply");

        bytes32 tokenIdHash = keccak256(abi.encodePacked(runeName));
        uint256 tokenId = uint256(tokenIdHash);
        require(_tokenInfos[tokenId].maxSupply == 0, "Token ID already exists");

        _tokenInfos[tokenId] = TokenInfo({
            uri: tokenURI,
            name: name,
            symbol: symbol,
            maxSupply: maxSupply,
            currentSupply: initialSupply,
            defaultMintAmount: defaultMintAmount
        });

        _mint(msg.sender, tokenId, initialSupply, "");
        _addUserToken(msg.sender, tokenId);
    }

    /**
     * @dev Mints a new non-fungible token in case the rune has only 1 unit on creation, and max cap of 1
     * @param tokenURI URI of the token
     * @param runeName Unique name of the rune
     * @param name Name of the token
     * @param symbol Symbol of the token
     */
    function mintNonFungible(
        string memory tokenURI,
        string memory runeName,
        string memory name,
        string memory symbol
    ) public onlyOwner {
        bytes32 tokenIdHash = keccak256(abi.encodePacked(runeName));
        uint256 tokenId = uint256(tokenIdHash);
        require(_tokenInfos[tokenId].maxSupply == 0, "Token ID already exists");

        _tokenInfos[tokenId] = TokenInfo({
            uri: tokenURI,
            name: name,
            symbol: symbol,
            maxSupply: 1,
            currentSupply: 1,
            defaultMintAmount: 1
        });

        _mint(msg.sender, tokenId, 1, "");
        _addUserToken(msg.sender, tokenId);
    }

    /**
     * @dev Mints more of an existing token, if the token is fungible and if the max supply has not been reached, it's defined as open minting due to the current runes design
     * @param runeName Bitcoin (unique) name of the rune to mint more of
     */
    function mintMore(string memory runeName) external {
        bytes32 tokenIdHash = keccak256(abi.encodePacked(runeName));
        uint256 tokenId = uint256(tokenIdHash);

        require(_tokenInfos[tokenId].maxSupply > 0, "Token ID does not exist");
        require(
            _tokenInfos[tokenId].currentSupply + _tokenInfos[tokenId].defaultMintAmount <= _tokenInfos[tokenId].maxSupply,
            "Exceeds max supply"
        );

        _mint(msg.sender, tokenId, _tokenInfos[tokenId].defaultMintAmount, "");
        _tokenInfos[tokenId].currentSupply += _tokenInfos[tokenId].defaultMintAmount;
        _addUserToken(msg.sender, tokenId);
    }

    /**
     * @dev Set the token URI
     * @param tokenId ID of the token to define URI for
     * @param tokenURI URI to set for the token (can be IPFS or HTTP(S) URL)
     */
    function _setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) internal virtual {
        _tokenInfos[tokenId].uri = tokenURI;
    }

    /**
     * @dev Returns the information of a token
     * @param tokenId ID of the token to query
     * @return TokenInfo struct containing the token's information
     */
    function getTokenInfo(
        uint256 tokenId
    ) public view returns (TokenInfo memory) {
        require(_tokenInfos[tokenId].maxSupply > 0, "Token ID does not exist");
        return _tokenInfos[tokenId];
    }

    /**
     * @dev Returns the token IDs owned by a user
     * @param user Address of the user to query
     * @return Array of token IDs owned by the user
     */
    function getUserTokens(
        address user
    ) public view returns (uint256[] memory) {
        return _userTokens[user];
    }

    /**
     * @dev Adds a token ID to the list of tokens owned by a user
     * @param user Address of the user
     * @param tokenId ID of the token to add
     */
    function _addUserToken(address user, uint256 tokenId) internal {
        bool tokenExists = false;
        for (uint256 i = 0; i < _userTokens[user].length; i++) {
            if (_userTokens[user][i] == tokenId) {
                tokenExists = true;
                break;
            }
        }
        if (!tokenExists) {
            _userTokens[user].push(tokenId);
        }
    }
}
