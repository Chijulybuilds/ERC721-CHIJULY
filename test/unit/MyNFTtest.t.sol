//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployMyNFT} from "../../script/DeployMyNFT.s.sol";
import {MyNFT} from "../../src/MyNFT.sol";

contract MyNFTTest is Test {
    DeployMyNFT public deployer;
    MyNFT public nft;

    address private immutable i_deployer = makeAddr("deployer");
    address private immutable i_bob = makeAddr("bob");

    string private constant Mock_TOKEN_URI = "ipfs://cool-monkey/0";
    string private constant Mock_SECOND_TOKEN_URI = "ipfs://cool-monkey/1";

    function setUp() public {
        deployer = new DeployMyNFT();
        vm.prank(i_deployer);
        nft = new MyNFT();
    }

    function testDeployScriptReturnsInitializedNFT() public {
        MyNFT deployedNft = deployer.run();

        assertEq(deployedNft.name(), "CoolMonkey");
        assertEq(deployedNft.symbol(), "CMK");
    }

    function testMintNftStoresTokenUriAndAssignsOwner() public {
        vm.prank(i_deployer);
        nft.mintNft(Mock_TOKEN_URI);

        assertEq(nft.ownerOf(0), i_deployer);
        assertEq(nft.balanceOf(i_deployer), 1);
        assertEq(nft.tokenURI(0), Mock_TOKEN_URI);
    }

    function testMintNftIncrementsTokenIdsSequentially() public {
        vm.startPrank(i_deployer);
        nft.mintNft(Mock_TOKEN_URI);
        nft.mintNft(Mock_SECOND_TOKEN_URI);
        vm.stopPrank();

        assertEq(nft.ownerOf(0), i_deployer);
        assertEq(nft.ownerOf(1), i_deployer);
        assertEq(nft.tokenURI(0), Mock_TOKEN_URI);
        assertEq(nft.tokenURI(1), Mock_SECOND_TOKEN_URI);
    }

    function testMintNftRevertsWhenCallerIsNotDeployer() public {
        vm.prank(i_bob);
        vm.expectRevert(MyNFT.MyNFT__NotDeployer.selector);
        nft.mintNft(Mock_TOKEN_URI);
    }
}
