const { TransactionDescription } = require("@ethersproject/abi");
const { SupportedAlgorithm } = require("@ethersproject/sha2");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Rentable", function () {
    let
        deployer,
        MockNft,
        nft,
        MockToken,
        token,
        MockInteractor,
        interact,
        user1,
        user2,
        RentableFactory,
        factory,
        Rentable,
        rental
    
    beforeEach(async() => {
      [
        deployer, 
        user1, 
        user2 
      ] = await ethers.getSigners();

      provider = ethers.getDefaultProvider();

      RentableFactory = await ethers.getContractFactory("RentableFactory");
      factory = await RentableFactory.deploy();

      MockNft = await ethers.getContractFactory("MockNft");
      nft = await MockNft.deploy();

      MockToken = await ethers.getContractFactory("MockToken");
      token = await MockToken.deploy();

      MockInteractor = await ethers.getContractFactory("MockInteractor");
      interact = await MockInteractor.deploy();

      Rentable = await ethers.getContractFactory("Rentable");
    });

    it("Setup successful", async function () {});

    it("Rental successful", async function () {
      await nft.mintNew();
      await factory.createNewRentable(token.address, '100000000000000000000');
      rental = await Rentable.attach(await factory.rentableContract(deployer.address, await factory.rentableNonce(deployer.address) - 1));
      let selector = await interact.getSelector(nft.address, 1);
      
      await nft.approve(rental.address, 1);
      await rental.depositNFT(nft.address, 1);
      await token.mint(user1.address, '10000000000000000000000');
      await token.connect(user1).approve(rental.address, '100000000000000000000');
      await rental.connect(user1).newRenter(user1.address);
      await rental.connect(user1).executeAction(
        nft.address,
        1,
        interact.address,
        selector
      );

      expect((await interact.val()).toString()).to.equal('1');
    });
});