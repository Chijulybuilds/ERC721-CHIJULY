//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MyNFT} from "../../src/MyNFT.sol";

contract MyNFTFuzzTest is Test {
    MyNFT private nft;
    address private immutable i_deployer = makeAddr("deployer");

    function setUp() public {
        vm.prank(i_deployer);
        nft = new MyNFT();
    }

    function testFuzzMintNftStoresUriAndOwner(string memory tokenUri) public {
        vm.prank(i_deployer);
        nft.mintNft(tokenUri);

        assertEq(nft.ownerOf(0), i_deployer);
        assertEq(nft.balanceOf(i_deployer), 1);
        assertEq(nft.tokenURI(0), tokenUri);
    }

    function testFuzzMintNftKeepsSequentialTokenState(string memory firstTokenUri, string memory secondTokenUri)
        public
    {
        vm.startPrank(i_deployer);
        nft.mintNft(firstTokenUri);
        nft.mintNft(secondTokenUri);
        vm.stopPrank();

        assertEq(nft.ownerOf(0), i_deployer);
        assertEq(nft.ownerOf(1), i_deployer);
        assertEq(nft.tokenURI(0), firstTokenUri);
        assertEq(nft.tokenURI(1), secondTokenUri);
    }

    function testFuzzMintNftRevertsForNonDeployer(address caller, string memory tokenUri) public {
        vm.assume(caller != i_deployer);

        vm.prank(caller);
        vm.expectRevert(MyNFT.MyNFT__NotDeployer.selector);
        nft.mintNft(tokenUri);
    }
}
