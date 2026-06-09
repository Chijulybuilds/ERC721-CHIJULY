// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MyDynamicNFT is ERC721 {

    uint256 private s_tokenCounter;
    string private s_happyMonkImageURI;
    string private s_sadMonkImageURI;
    mapping(uint256 => string) private s_tokenIDToURI;
    mapping(uint256 => MOOD) private s_tokenIDToMood;
    error ERC721_TokenDoesNotExist();
    error ERC721_UnauthorizedOperator(address operator);

    enum MOOD {
        SAD,
        HAPPY
    }
    
    modifier OnlyOwnerOfToken(uint256 tokenId) {
        if (msg.sender != ownerOf(tokenId)) {
            revert ERC721_UnauthorizedOperator(msg.sender);
        }
        _;
    }

    constructor(string memory happyMonkImageURI, string memory sadMonkImageURI) ERC721("MyDynamicNFT", "MDNFT") {
        s_tokenCounter = 0;
        s_happyMonkImageURI = happyMonkImageURI;
        s_sadMonkImageURI = sadMonkImageURI;
    }

    function mintNFT() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIDToMood[s_tokenCounter] = MOOD.SAD;
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;

        if (tokenId >= s_tokenCounter) {
            revert ERC721_TokenDoesNotExist();
        }

        if (s_tokenIDToMood[tokenId] == MOOD.SAD) {
            imageURI = s_sadMonkImageURI;
        } else {
            imageURI = s_happyMonkImageURI;
        }
        bytes memory tokenMetadata = abi.encodePacked(
            "{",
            '"name":"MyDynamicNFT",',
            '"description":"A dynamic NFT that changes based on its state",',
            '"image":"',
            imageURI,
            '",',
            '"attributes":[{',
            '"trait_type":"Moodiness",',
            '"value":"100"',
            "}]",
            "}"
        );

        return string(abi.encodePacked(_baseURI(), Base64.encode(bytes(tokenMetadata))));
    }

    function getSadMonkImageURI() public view returns (string memory) {
        return s_sadMonkImageURI;
    }

    function getHappyMonkImageURI() public view returns (string memory) {
        return s_happyMonkImageURI;
    }

    function flipMood(uint256 tokenId) public OnlyOwnerOfToken(tokenId) {
        if (tokenId >= s_tokenCounter) {
            revert ERC721_TokenDoesNotExist();
        }
        if (s_tokenIDToMood[tokenId] == MOOD.SAD) {
            s_tokenIDToMood[tokenId] = MOOD.HAPPY;
        } else {
            s_tokenIDToMood[tokenId] = MOOD.SAD;
        }
    }
}
