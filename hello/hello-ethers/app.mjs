import { ethers } from "ethers";
const provider = ethers.getDefaultProvider();

const main = () => {
    provider.getNetwork().then(network => {
        console.log("network: ", network);
    });

    // const balance = await provider.getBalance("0x41b309236C87b1bc6FA8Eb865833E44158Fa991a");
    // console.log(`0x41b309236C87b1bc6FA8Eb865833E44158Fa991a: ` + ethers.utils.formatEther(balance));

    // const blockNumber = await provider.getBlockNumber();
    // console.log("blockNumber: ", blockNumber);

    // const gasPrice = await provider.getGasPrice();
    // console.log("gasPrice: ", ethers.utils.formatEther(gasPrice));
    // console.log();

    // const feeData = await provider.getFeeData();
    // console.log("feeData: ", feeData);
    // console.log();

    // const block = await provider.getBlock(16294483);
    // console.log("block: ", block);
    // console.log();

    // const code = await provider.getCode([0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984]);
    // console.log("code: ", code);
    // console.log();

}
main();