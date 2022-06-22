//SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./interfaces/IERC20.sol";
import "./interfaces/IAave.sol";
import "./interfaces/ISwapImplementation.sol";
import "./test/utils/console.sol";

contract AaveImplementation {
    /*
         .-.
        (o o) boo!
        | O \
        \   \
        `~~~'
    */
    ILendingPool aaveLender =
        ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function leverageLong(
        address _asset,
        address _swapper,
        uint256 _initialCollateralAmount
    ) external returns (uint256, uint256) {
        IERC20(_asset).transferFrom(
            msg.sender,
            address(this),
            _initialCollateralAmount
        );
        IERC20(_asset).approve(address(aaveLender), _initialCollateralAmount);
        console.log("1");
        console.log(IERC20(WETH).balanceOf(address(this)));

        deposit(_asset, _initialCollateralAmount);
        console.log("1");
        console.log(IERC20(WETH).balanceOf(address(this)));

        aaveLender.setUserUseReserveAsCollateral(_asset, true);
        uint256 nextBorrow = _initialCollateralAmount;
        uint256 totalBorrow;
        uint256 totalCollateral = _initialCollateralAmount;
        console.log("1");

        // After 3 loops law of diminishing returns really kills you
        for (uint i = 0; i < 2; i++) {
            uint borrowAmount = ((totalCollateral * uint256(32)) / 100);
            console.log(borrowAmount);
            console.log(totalCollateral);
            console.log(IERC20(DAI).balanceOf(address(this)));

            borrow(DAI, borrowAmount);
            totalBorrow += borrowAmount;
            // (address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to
            IERC20(DAI).approve(_swapper, borrowAmount);
            console.log(IERC20(DAI).balanceOf(address(this)));
             
            IERC20(address(DAI)).approve(_swapper, borrowAmount);

            uint256 tokensBought = swapImplementation(_swapper).swap(
                address(DAI),
                _asset,
                borrowAmount,
                1,
                address(this)
            );
            uint256 nextBorrow = tokensBought;

            // Re-approving each deposit sucks, but is signficiantly safer
            IERC20(_asset).approve(address(aaveLender), tokensBought);
            deposit(_asset, tokensBought);
            totalCollateral += tokensBought;
        }
        return (totalBorrow, totalCollateral);
    }

    function leverageShort(
        address _asset,
        address _swapper,
        uint256 _initialCollateralAmount,
        uint256 _initialBorrowAmount,
        uint256 _borrowFactor
    ) external returns (uint256, uint256) {
        IERC20(DAI).transferFrom(
            msg.sender,
            address(this),
            _initialCollateralAmount
        );
        IERC20(DAI).approve(address(aaveLender), _initialCollateralAmount);
        deposit(DAI, _initialCollateralAmount);
        aaveLender.setUserUseReserveAsCollateral(DAI, true);
        uint256 nextBorrow = _initialBorrowAmount;
        uint256 totalBorrow;
        uint256 totalCollateral = _initialCollateralAmount;
        // Highly leveraged shorts breaks a lot of things, so I've limited it for now
        uint borrowAmount = (nextBorrow * _borrowFactor) / 100;
        borrow(_asset, borrowAmount);
        totalBorrow += borrowAmount;
        // (address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to
        IERC20(_asset).approve(_swapper, borrowAmount);
        uint256 tokensBought = swapImplementation(_swapper).swap(
            _asset,
            DAI,
            borrowAmount,
            1,
            address(this)
        );
        IERC20(DAI).approve(address(aaveLender), tokensBought);
        deposit(DAI, tokensBought);
        totalCollateral += tokensBought;

        return (totalBorrow, totalCollateral);
    }

    function closePosition(
        address _debtAsset,
        address _asset,
        address _swapper,
        uint256 _debtOwed,
        uint256 _totalCollateral
    ) public {
        IERC20(_debtAsset).transferFrom(msg.sender, address(this), _debtOwed);
        IERC20(_debtAsset).approve(address(aaveLender), _debtOwed);
        repay(_debtAsset, _debtOwed);
        // Now with no debt, withdraw collateral
        uint256 amountWithdrawn = withdraw(_asset, _totalCollateral);
        IERC20(_asset).transfer(msg.sender, _totalCollateral);
    }

    /*
        Internal Wrapper functions for dealing with Aave directly
    */
    function deposit(address _asset, uint256 _amount) public {
        IERC20(_asset).approve(address(aaveLender), _amount);

        //aaveLender.setUserUseReserveAsCollateral(_asset, true);
        aaveLender.deposit(_asset, _amount, address(this), 0);
    }

    function depositMoney(uint256 _amount, uint256 _borrowME) public {
        IERC20(DAI).transferFrom(msg.sender, address(this), _amount);

        IERC20(DAI).approve(address(aaveLender), _amount);

        deposit(DAI, _amount);

        aaveLender.setUserUseReserveAsCollateral(DAI, true);

        borrow(DAI, _borrowME);
    }

    function withdraw(address _asset, uint256 _amount)
        internal
        returns (uint256)
    {
        uint256 amountReturned = aaveLender.withdraw(
            _asset,
            _amount,
            address(this)
        );
    }

    function borrow(address _asset, uint256 _amount) internal {
        aaveLender.borrow(_asset, _amount, 2, 0, address(this));
    }

    function repay(address _asset, uint256 _amount) internal returns (uint256) {
        uint256 amountRepayed = aaveLender.repay(
            _asset,
            _amount,
            2,
            address(this)
        );
        return amountRepayed;
    }
}
