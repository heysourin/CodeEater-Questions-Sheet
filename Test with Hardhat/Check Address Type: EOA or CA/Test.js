const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
// const {  keccak256} = require("chai");

describe("Address type checks", function () {
  async function deployOneYearLockFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("Test");
    const contract = await Contract.deploy();

    return { contract, owner, otherAccount };
  }

  describe("Test Address Type: 'checkAddressType()' ", function () {
    it("Should return address type Contract Account, true", async function () {
      const { contract, otherAccount } = await loadFixture(
        deployOneYearLockFixture
      );

      const contractAddress = contract.address;
      // console.log(contract.address);
      expect(await contract.checkAddressType(contractAddress)).to.equal(
        "Contract Account"
      );
    });
    it("Should return address type EOA, true", async function () {
      const { contract, otherAccount } = await loadFixture(
        deployOneYearLockFixture
      );

      const EOAAddress = otherAccount.address;
      // console.log(EOAAddress);
      expect(await contract.checkAddressType(EOAAddress)).to.equal(
        "Externally Owned Account"
      );
    });
  });

  describe("Test Address Type: 'checkContract()' ", function () {
    it("Should return true when contract address has been passed", async function () {
      const { contract, otherAccount } = await loadFixture(
        deployOneYearLockFixture
      );

      const contractAddress = contract.address;
      expect(await contract.checkContract(contractAddress)).to.equal(true);
    });
  });
});
