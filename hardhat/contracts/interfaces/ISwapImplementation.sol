// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface swapImplementation {
    function Swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint _amountOutMin, address _to) external returns(uint);

    function _getAmountOutMin(address _tokenIn, address _tokenOut, uint _amountIn) external view returns (uint);
}