// SPDX=License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title MyNFT
 * @dev A simple NFT contract that represents NFT collection
 */

contract MyNFT is ERC721 {
    uint256 private s_nftTokenCounter;
    address private immutable i_deployer;

    mapping(uint256 => string) private s_tokenIdToUri;

    error MyNFT__NotDeployer();
    error MyNFT__TokenNotFound();

    modifier OnlyDeployer() {
        if (msg.sender != i_deployer) {
            revert MyNFT__NotDeployer();
        }
        _;
    }

    constructor() ERC721("CoolMonkey", "CMK") {
        i_deployer = msg.sender;
        s_nftTokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public OnlyDeployer {
        s_tokenIdToUri[s_nftTokenCounter] = tokenUri;
        _safeMint(msg.sender, s_nftTokenCounter);
        s_nftTokenCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }

    function getTokenId(string memory tokenUri) public view returns (uint256) {
        for (uint256 i = 0; i < s_nftTokenCounter; i++) {
            if (keccak256(bytes(s_tokenIdToUri[i])) == keccak256(bytes(tokenUri))) {
                return i;
            }
        }
        revert MyNFT__TokenNotFound();
    }
}
