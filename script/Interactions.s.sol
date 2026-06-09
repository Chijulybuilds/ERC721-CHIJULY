// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
// DevOps used for identifying the most recently deployed address
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {MyNFT} from "../src/MyNFT.sol";

contract MintNFT is Script {
    error MintNFT__InvalidNftAddress();

    function mintNFT(address nftAddress, string memory tokenUri) public {
        if (nftAddress == address(0) || nftAddress.code.length == 0) {
            revert MintNFT__InvalidNftAddress();
        }

        vm.startBroadcast();
        MyNFT(nftAddress).mintNft(tokenUri);
        vm.stopBroadcast();
    }

    function run() external {
        // we need to get most recently deployed contract to interact with
        address mostRecentDeploy = DevOpsTools.get_most_recent_deployment("MyNFT", block.chainid);
        string memory tokenUri = vm.envString("NFT_TOKEN_URI");
        mintNFT(mostRecentDeploy, tokenUri);
    }
}
