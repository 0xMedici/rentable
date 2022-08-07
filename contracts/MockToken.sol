//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Import this file to use console.log
import "hardhat/console.sol";

contract MockToken is ERC20 { 

    uint256 public id;

    constructor() ERC20("Test", "TST") {}

    function mint(address _recipient, uint256 _amount) external {
        _mint(_recipient, _amount);
    }
}