//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Import this file to use console.log
import "hardhat/console.sol";

contract MockInteractor { 

    uint256 public val;

    constructor() {}

    function increment(
        address _nft,
        uint256 _id
    ) external {
        console.log("T");
        IERC721(_nft).transferFrom(msg.sender, address(this), _id);
        val++;
        IERC721(_nft).transferFrom(address(this), msg.sender, _id);
    }

    function getSelector(address _nft, uint256 _id) external view returns(bytes memory) {
        bytes4 firstSelector = MockInteractor(address(this)).increment.selector;
        bytes memory data = abi.encodeWithSelector(firstSelector, _nft, _id);
        return data;
    }
}