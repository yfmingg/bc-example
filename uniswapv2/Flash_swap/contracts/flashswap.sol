// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/Uniswap.sol";

// uniswap will call this function when we execute the flash swap
interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

// flash swap contract
contract flashSwap is IUniswapV2Callee {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // https://docs.uniswap.org/contracts/v2/reference/smart-contracts/factory
    address private constant UniswapV2Factory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;


    // we'll call this function to call to call FLASHLOAN on uniswap
    // 这是我们要调用的函数，用来触发闪电兑换交易。
    // _tokenBorrow是要从Uniswap借入的代币Token地址（哪种代币），_amount我们想借入的该代币的数量
    function testFlashSwap(address _tokenBorrow, uint256 _amount) external {
        // check the pair contract for token borrow and weth exists
        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(
            _tokenBorrow,
            WETH
        );
        require(pair != address(0), "!pair");

        // right now we dont know tokenborrow belongs to which token
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        // as a result, either amount0out will be equal to 0 or amount1out will be
        uint256 amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint256 amount1Out = _tokenBorrow == token1 ? _amount : 0;

        // 这和我们在Uniswap上执行简单兑换时调用的函数完全一样。
        // 唯一的区别是最后一个参数。如果它是空的，那么Uniswap将尝试执行一个简单的兑换。
        // 如果最后一个参数不是空的，而是有附加数据，那么它将会触发一个闪电兑换。
        // 为了传递输入参数，我们将把tokenBorrow和amount编码为字节，然后传递给swap函数。
        // need to pass some data to trigger uniswapv2call
        bytes memory data = abi.encode(_tokenBorrow, _amount);
        // last parameter tells whether its a normal swap or a flash swap
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
        // adding data triggers a flashloan
    }

    // in return of flashloan call, uniswap will return with this function
    // providing us the token borrow and the amount
    // we also have to repay the borrowed amt plus some fees
    // 这是Uniswap合约调用的函数,IUniswapV2Callee接口的抽象方法
    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external override {
        // 检查这个函数只能由LP 配对合约（即 LP 合约）调用。
        // 因此还将检查调用者（msg.sender）是否等于配对合约。
        // check msg.sender is the pair contract
        // take address of token0 n token1
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        // call uniswapv2factory to getpair 
        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(token0, token1);
        require(msg.sender == pair, "!pair");
        // check sender holds the address who initiated the flash loans
        require(_sender == address(this), "!sender");

        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));

        // TODO: 可以通过其他DEX进行套利操作

        // 0.3% fees
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;

        // 还款
        IERC20(tokenBorrow).transfer(pair, amountToRepay);
    }
}
