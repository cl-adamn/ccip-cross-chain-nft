// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    struct TokenInfo {
        address buyer;
        address seller;
        uint256 value;
        uint256 date;
        string status;
    }

    mapping(uint256 => TokenInfo) private _tokenInfo;

    uint256 private _tokenIdCounter;

    event Minted(address indexed owner, uint256 tokenId, address buyer, address seller, uint256 value, uint256 date);

    constructor() ERC721("Letter of Credit", "LOC") Ownable(msg.sender) {
        _tokenIdCounter = 0;
    }

    function mint(address buyer, address seller, uint256 value) external onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(seller, tokenId);

        _tokenInfo[tokenId] = TokenInfo({
            buyer: buyer,
            seller: seller,
            value: value,
            issued: block.timestamp,
            status: "submitted"
        });

        _tokenIdCounter++;
    }


}
