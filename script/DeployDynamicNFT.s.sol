//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {MyDynamicNFT} from "src/MyDynamicNFT.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployDynamicNFT is Script {
    function run() external returns (MyDynamicNFT) {

        string memory happySVG = vm.readFile("./images/happyMonk.svg");
        string memory sadSVG = vm.readFile("./images/sadMonk.svg");
        string memory HAPPY_IMAGE_URI = svgToImageURI(happySVG);
        string memory SAD_IMAGE_URI = svgToImageURI(sadSVG);

        vm.startBroadcast();
        MyDynamicNFT Dynamicnft = new MyDynamicNFT(HAPPY_IMAGE_URI, SAD_IMAGE_URI);
        vm.stopBroadcast();
        return Dynamicnft;
    }

    function svgToImageURI(string memory svg) public pure returns(string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));

        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
