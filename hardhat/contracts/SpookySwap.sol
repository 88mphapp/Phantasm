// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interfaces/IPhantasm.sol';
import './interfaces/IUniswapV2.sol';
import './interfaces/IERC20.sol';


contract SpookySwapper {


    IUniswapV2Router public SpookyRouter = IUniswapV2Router(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
    IERC20 public WFTM = IERC20(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);

    function Swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint _amountOutMin, address _to) public returns(uint) {

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        IERC20(_tokenIn).approve(address(SpookyRouter), _amountIn);

        address[] memory path;
        
        // Quick logic routing as ETH is a common pairing
        // @TODO add routing check for stablecoins like DAI as well
        if (_tokenIn == address(WFTM) || _tokenOut == address(WFTM)) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = address(WFTM);
            path[2] = _tokenOut;
        }

        uint [] memory test= SpookyRouter.swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);



        IERC20(_tokenOut).transfer(msg.sender, IERC20(_tokenOut).balanceOf(address(this)));
        return test[2];

    }

    function _getAmountOutMin(address _tokenIn, address _tokenOut, uint _amountIn) public view returns (uint) {
        address[] memory path;
        if (_tokenIn == address(WFTM) || _tokenOut == address(WFTM)) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = address(WFTM);
            path[2] = _tokenOut;
        }

        uint[] memory amountOutMins = SpookyRouter.getAmountsOut(_amountIn, path);

        return amountOutMins[path.length - 1];
    }
}
