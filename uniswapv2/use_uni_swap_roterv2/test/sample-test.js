const { BigNumber } = require("@ethersproject/bignumber");
const { expect } = require("chai");
const { ethers } = require("hardhat");

// const IERC20ABI = ("../artifacts/contracts/interfaces/IERC20.sol/IERC20.json");
const ERC20ABI = require("@uniswap/v2-core/build/ERC20.json").abi;

// 用DAI 去换 WETH
describe("Test Swap", function () {

    /**
     * DAIAddress和WETHAddress分别是Dai 合约和WETH 合约的地址，它们将在交易中使用
     * ToWETHHolder是交易者的地址。
     * FromDAIHolder是我们要冒充的地址。
     */
    const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

    // 花费FromDAIHolder账户的DAI，换取WETH到ToWETHHolder账户
    const ToWETHHolder = "0xf04a5cc80b1e94c69b48f5ee68a08cd2f09a7c3e";
    const FromDAIHolder = "0xb527a981e1d415af696936b3174f2d7ac8d11369"; 
    let TestSwapContract;

    beforeEach(async () => {
        const TestSwapFactory = await ethers.getContractFactory("testSwap");
        TestSwapContract = await TestSwapFactory.deploy();
        await TestSwapContract.deployed();
    })

    it("should swap", async () => {
        // impersonate acc
        // 为测试脚本创建一个测试用例，并“冒充”我们之前定义的FromDAIHolder地址。
        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [FromDAIHolder],
        });
        const impersonateSigner = await ethers.getSigner(FromDAIHolder);

        // DAI contract
        const DAIContract = new ethers.Contract(DAIAddress, ERC20ABI, impersonateSigner)
        const FromDAIHolderBalance = await DAIContract.balanceOf(impersonateSigner.address)
        await DAIContract.approve(TestSwapContract.address, FromDAIHolderBalance)

        // getting my initial DAI balance
        const WETHContract = new ethers.Contract(WETHAddress, ERC20ABI, impersonateSigner)
        const myBalance = await WETHContract.balanceOf(ToWETHHolder);
        console.log("ToWETHHolder Initial WETH Balance:", ethers.utils.formatUnits(myBalance.toString()));
        console.log("FromDAIHolder Initial DAI Balance:", ethers.utils.formatUnits(FromDAIHolderBalance.toString()));

        // getting current timestamp
        const latestBlock = await ethers.provider.getBlockNumber();
        const timestamp = (await ethers.provider.getBlock(latestBlock)).timestamp;

        await TestSwapContract.connect(impersonateSigner).swap(
            DAIAddress,
            WETHAddress,
            FromDAIHolderBalance,
            ToWETHHolder,
            timestamp + 100 // adding 100 seconds to the current blocktime
        )

        const myBalance_updated = await WETHContract.balanceOf(ToWETHHolder);
        console.log("ToWETHHolder Balance after Swap:", ethers.utils.formatUnits(myBalance_updated.toString()));
        
        const FromDAIHolderBalance_updated = await DAIContract.balanceOf(impersonateSigner.address);
        console.log("FromDAIHolder Balance after Swap:", ethers.utils.formatUnits(FromDAIHolderBalance_updated.toString()));
        
        // expect(FromDAIHolderBalance_updated.eq(BigNumber.from(0))).to.be.true
        // expect(myBalance_updated.gt(myBalance)).to.be.true;
    })
})
