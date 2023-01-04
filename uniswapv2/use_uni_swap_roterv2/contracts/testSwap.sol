// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./interfaces/IERC20.sol";
import "./interfaces/Uniswap.sol";

contract testSwap {
    uint256 deadline;
    //address of the uniswap v2 router
    //https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02
    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


    // swap function
    /**
    _tokenIn： 是我们要兑换的代币的地址。
    _tokenOut：是我们想从这次交易中获得的代币的地址。
    _amountIn： 是我们要交易的代币的数量。
    _to：交易兑换出的代币发送到这个地址。
    _deadline：是交易应该被执行的时间期限。如果超过了最后期限，交易就会失败。
     */
    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        address _to,
        uint256 _deadline
      
    ) external {
        // transfer the amount in tokens from msg.sender to this contract
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        // by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract
        // _allowances[msg.sender][UNISWAP_V2_ROUTER] = _amountIn;
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn; 
        path[1] = _tokenOut; 

        uint256[] memory amountsExpected = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(
            _amountIn,
            path
        );
     
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            amountsExpected[0],
            (amountsExpected[1]*990)/1000, // accpeting a slippage of 1%
            path,
            _to,
            _deadline
        );
    }
}
