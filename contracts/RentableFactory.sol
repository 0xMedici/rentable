// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Rentable } from "./Rentable.sol";
import { RentableLocked } from "./RentableLocked.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

// Import this file to use console.log
import "hardhat/console.sol";

contract RentableFactory {

   address private immutable _rentableImpl;
   address private immutable _rentableLockedImpl;

   mapping(address => uint256) public rentableNonce;
   mapping(address => uint256) public rentableLockedNonce;
   mapping(address => mapping(uint256 => address)) public rentableContract;
   mapping(address => mapping(uint256 => address)) public rentableLockedContract;

   event FlashClaimCreated(address _addr, address _creator, uint256 nonce);

   constructor() {
      _rentableImpl = address(new Rentable());
      _rentableLockedImpl = address(new RentableLocked());
   }
   
   function createNewRentable(address _currency, uint256 _price) external {
      Rentable rentableDeployment = Rentable(
         Clones.clone(_rentableImpl)
      );

      rentableDeployment.initialize(
         msg.sender,
         _currency,
         _price
      );

      rentableContract[msg.sender][rentableNonce[msg.sender]] = address(rentableDeployment);
      rentableNonce[msg.sender]++;
   }

   function createNewRentableLocked(address _currency, uint256 _price, uint256 _rentalLength) external {
      RentableLocked rentableDeployment = RentableLocked(
         Clones.clone(_rentableImpl)
      );

      rentableDeployment.initialize(
         msg.sender,
         _currency,
         _price,
         _rentalLength
      );

      rentableLockedContract[msg.sender][rentableLockedNonce[msg.sender]] = address(rentableDeployment);
      rentableLockedNonce[msg.sender]++;
   }
}
