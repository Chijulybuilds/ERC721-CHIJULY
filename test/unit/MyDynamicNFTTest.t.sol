// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployDynamicNFT} from "../../script/DeployDynamicNFT.s.sol";
import {MyDynamicNFT} from "../../src/MyDynamicNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MyDynamicNFTTest is Test {
    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/

    MyDynamicNFT public myDynamicNFT;

    address public USER = makeAddr("user");

    uint256 public constant TOKEN_ID = 0;

    /*//////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() external {
        DeployDynamicNFT deployer = new DeployDynamicNFT();
        myDynamicNFT = deployer.run();
        vm.etch(USER, "");
    }

    /*//////////////////////////////////////////////////////////////
                        tokenURI() TESTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Tests tokenURI reverts if token does not exist
     */
    function testTokenURIRevertsIfTokenDoesNotExist() public {
        vm.expectRevert(MyDynamicNFT.ERC721_TokenDoesNotExist.selector);

        myDynamicNFT.tokenURI(999);
    }

    /**
     * @notice Tests SAD mood branch
     */
    function testTokenURIReturnsSadImageURI() public {
        vm.prank(USER);

        if (block.chainid == 11155111 || block.chainid == 31337) {
            myDynamicNFT.mintNFT();
        }

        string memory actualTokenURI = myDynamicNFT.tokenURI(TOKEN_ID);

        string memory sadImageURI = myDynamicNFT.getSadMonkImageURI();

        bytes memory expectedMetadata = abi.encodePacked(
            "{",
            '"name":"MyDynamicNFT",',
            '"description":"A dynamic NFT that changes based on its state",',
            '"image":"',
            sadImageURI,
            '",',
            '"attributes":[{',
            '"trait_type":"Moodiness",',
            '"value":"100"',
            "}]",
            "}"
        );

        string memory expectedTokenURI =
            string(abi.encodePacked("data:application/json;base64,", Base64.encode(expectedMetadata)));

        assertEq(actualTokenURI, expectedTokenURI);
    }

    /**
     * @notice Tests HAPPY mood branch
     */
    function testTokenURIReturnsHappyImageURI() public {
        vm.prank(USER);

        if (block.chainid == 11155111 || block.chainid == 31337) {
            myDynamicNFT.mintNFT();
        }

        vm.prank(USER);

        myDynamicNFT.flipMood(TOKEN_ID);

        string memory actualTokenURI = myDynamicNFT.tokenURI(TOKEN_ID);

        string memory happyImageURI = myDynamicNFT.getHappyMonkImageURI();

        bytes memory expectedMetadata = abi.encodePacked(
            "{",
            '"name":"MyDynamicNFT",',
            '"description":"A dynamic NFT that changes based on its state",',
            '"image":"',
            happyImageURI,
            '",',
            '"attributes":[{',
            '"trait_type":"Moodiness",',
            '"value":"100"',
            "}]",
            "}"
        );

        string memory expectedTokenURI =
            string(abi.encodePacked("data:application/json;base64,", Base64.encode(expectedMetadata)));
    
        assertEq(actualTokenURI, expectedTokenURI);
    }

    /**
     * @notice Tests returned URI starts with correct base URI
     */
    function testTokenURIContainsBase64Prefix() public {
        vm.prank(USER);

        if (block.chainid == 11155111 || block.chainid == 31337) {
            myDynamicNFT.mintNFT();
        }

        string memory tokenUri = myDynamicNFT.tokenURI(TOKEN_ID);

        string memory expectedPrefix = "data:application/json;base64,";

        bytes memory tokenUriBytes = bytes(tokenUri);

        bytes memory prefixBytes = bytes(expectedPrefix);

        for (uint256 i = 0; i < prefixBytes.length; i++) {
            assertEq(tokenUriBytes[i], prefixBytes[i]);
        }
    }

    /**
     * @notice Tests metadata is not empty
     */
    function testTokenURINotEmpty() public {
        vm.prank(USER);

        if (block.chainid == 11155111 || block.chainid == 31337) {
            myDynamicNFT.mintNFT();
        }

        string memory tokenUri = myDynamicNFT.tokenURI(TOKEN_ID);

        assertGt(bytes(tokenUri).length, 0);
    }

    /**
     * @notice Tests multiple minted NFTs return valid URIs
     */
    function testMultipleMintedNFTsReturnValidURIs() public {
        vm.startPrank(USER);

        if (block.chainid == 11155111 || block.chainid == 31337) {
            myDynamicNFT.mintNFT();
            myDynamicNFT.mintNFT();
            myDynamicNFT.mintNFT();
        }

        vm.stopPrank();

        string memory tokenURI0 = myDynamicNFT.tokenURI(0);

        string memory tokenURI1 = myDynamicNFT.tokenURI(1);

        string memory tokenURI2 = myDynamicNFT.tokenURI(2);

        assertGt(bytes(tokenURI0).length, 0);
        assertGt(bytes(tokenURI1).length, 0);
        assertGt(bytes(tokenURI2).length, 0);
    }

    /**
     * @notice Tests tokenURI changes after mood flip
     */
    function testTokenURIChangesAfterMoodFlip() public {
        vm.prank(USER);

        if (block.chainid == 11155111 || block.chainid == 31337) {
            myDynamicNFT.mintNFT();
        }

        string memory initialURI = myDynamicNFT.tokenURI(TOKEN_ID);

        vm.prank(USER);

        myDynamicNFT.flipMood(TOKEN_ID);

        string memory updatedURI = myDynamicNFT.tokenURI(TOKEN_ID);

        assertTrue(keccak256(bytes(initialURI)) != keccak256(bytes(updatedURI)));
    }

    /**
     * @notice Tests deterministic tokenURI
     */
    function testTokenURIIsDeterministic() public {
        vm.prank(USER);

        if (block.chainid == 11155111 || block.chainid == 31337) {
            myDynamicNFT.mintNFT();

            string memory uri1 = myDynamicNFT.tokenURI(TOKEN_ID);

            string memory uri2 = myDynamicNFT.tokenURI(TOKEN_ID);

            assertEq(uri1, uri2);
        }

    }
}
