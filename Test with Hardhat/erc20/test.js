const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("MyToken", function () {
  async function runEveryTime() {
    const [owner, user1, user2] = await ethers.getSigners();

    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy();
    await myToken.deployed();

    return { myToken, owner, user1, user2 };
  }

  it("should check the state variables", async function () {
    const { myToken } = await loadFixture(runEveryTime);
    expect(await myToken.name()).to.equal("My Token");
    expect(await myToken.symbol()).to.equal("MTK");
    expect(await myToken.totalSupply()).to.equal(
      BigInt("1000000000000000000000000")
    );
    expect(await myToken.decimals()).to.equal(18);
  });

  it("should transfer tokens correctly", async function () {
    const { myToken, owner, user1, user2 } = await loadFixture(runEveryTime);

    const ownerBalanceBefore = await myToken.balanceOf(
      await owner.getAddress()
    );
    const user1BalanceBefore = await myToken.balanceOf(
      await user1.getAddress()
    );

    // console.log(ownerBalanceBefore);
    // console.log(user1BalanceBefore);
    await myToken.transfer(await user1.getAddress(), 100);

    const ownerBalanceAfter = await myToken.balanceOf(await owner.getAddress());
    const user1BalanceAfter = await myToken.balanceOf(await user1.getAddress());
    // console.log(ownerBalanceAfter);
    // console.log(user1BalanceAfter);
    expect(ownerBalanceAfter).to.equal(
      BigInt(ownerBalanceBefore) - BigInt(100)
    );
    expect(user1BalanceAfter).to.equal(user1BalanceBefore + 100);
  });

  it("should approve and transferFrom tokens correctly", async function () {
    const { myToken, owner, user1, user2 } = await loadFixture(runEveryTime);

    const ownerAddress = await owner.getAddress();
    const user1Address = await user1.getAddress();
    const user2Address = await user2.getAddress();

    //acting as owner and approving user1 to spend 100
    await myToken.approve(user1Address, 100);

    expect(await myToken.allowance(ownerAddress, user1Address)).to.equal(100);

    //Here acting as user1 and transfering those 100 approved tokens to user2
    await myToken.connect(user1).transferFrom(ownerAddress, user2Address, 50);

    expect(await myToken.balanceOf(user2Address)).to.equal(50);
    expect(await myToken.balanceOf(ownerAddress)).to.equal(
      BigInt("999999999999999999999950")
    );
  });
});
