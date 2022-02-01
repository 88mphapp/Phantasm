// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


import "./interfaces/IERC20.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/ISwapImplementation.sol";
import "./test/utils/console.sol";


contract GeistImplementation {
    /*
         .-.
        (o o) boo!
        | O \
        \   \
        `~~~'
    */
    ILendingPool geistLender = ILendingPool(0x9FAD24f572045c7869117160A571B2e50b10d068);

    address public constant DAI = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;

    function leverageLong(address _asset, address _swapper, uint256 _initialCollateralAmount, uint256 _initialBorrowAmount, uint256 _borrowFactor) external returns (uint256, uint256) {
        
        IERC20(_asset).transferFrom(msg.sender, address(this), _initialCollateralAmount);
        IERC20(_asset).approve(address(geistLender), _initialCollateralAmount);

        deposit(_asset, _initialCollateralAmount);
        geistLender.setUserUseReserveAsCollateral(_asset, true);
        uint256 nextBorrow = _initialCollateralAmount;
        uint256 totalBorrow;
        uint256 totalCollateral = _initialCollateralAmount;
        // After 3 loops law of diminishing returns really kills you
        for(uint i = 0; i < 3; i++){
            uint borrowAmount = (nextBorrow * _borrowFactor) / 100;
            borrow(DAI, borrowAmount);
            totalBorrow += borrowAmount;
            // (address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to
            IERC20(DAI).approve(_swapper, borrowAmount);
            uint256 tokensBought = swapImplementation(_swapper).swap(DAI, _asset,borrowAmount, 1, address(this));
            uint256 nextBorrow = tokensBought;
            // Re-approving each deposit sucks, but is signficiantly safer
            IERC20(_asset).approve(address(geistLender), tokensBought);
            deposit(_asset, tokensBought);
            totalCollateral += tokensBought;
        }
        return (totalBorrow, totalCollateral);
        
    }

    function leverageShort(address _asset, address _swapper, uint256 _initialCollateralAmount, uint256 _initialBorrowAmount, uint256 _borrowFactor) external returns (uint256, uint256) {
        IERC20(DAI).transferFrom(msg.sender, address(this), _initialCollateralAmount);
        IERC20(DAI).approve(address(geistLender), _initialCollateralAmount);
        deposit(DAI, _initialCollateralAmount);
        geistLender.setUserUseReserveAsCollateral(DAI, true);
        uint256 nextBorrow = _initialBorrowAmount;
        uint256 totalBorrow;
        uint256 totalCollateral = _initialCollateralAmount;
        // Highly leveraged shorts breaks a lot of things, so I've limited it for now
        uint borrowAmount = (nextBorrow * _borrowFactor) / 100;
        borrow(_asset, borrowAmount);
        totalBorrow += borrowAmount;
        // (address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to
        IERC20(_asset).approve(_swapper, borrowAmount);
        uint256 tokensBought = swapImplementation(_swapper).swap(_asset,DAI,borrowAmount, 1, address(this));
        IERC20(DAI).approve(address(geistLender), tokensBought);
        deposit(DAI, tokensBought);
        totalCollateral += tokensBought;
    
        return (totalBorrow, totalCollateral);
        
    }
    
    function closePosition(address _debtAsset, address _asset, address _swapper, uint256 _debtOwed, uint256 _totalCollateral) public {
        IERC20(_debtAsset).transferFrom(msg.sender, address(this), _debtOwed);
        IERC20(_debtAsset).approve(address(geistLender), _debtOwed);
        repay(_debtAsset, _debtOwed);
        // Now with no debt, withdraw collateral
        uint256 amountWithdrawn = withdraw(_asset, _totalCollateral);
        IERC20(_asset).transfer(msg.sender, _totalCollateral);
    }

    /*
        Internal Wrapper functions for dealing with Aave directly
    */
    function deposit(
        address _asset, 
        uint256 _amount
    ) public {
        IERC20(_asset).approve(address(geistLender), _amount);
        //geistLender.setUserUseReserveAsCollateral(_asset, true);

        geistLender.deposit(_asset, _amount, 0x6Ab30d124cf23aEaEd9Aff8887b2E73f034796ca, 0);

    }



    function depositMoney(uint256 _amount, uint256 _borrowME) public {

        IERC20(DAI).transferFrom(msg.sender, address(this), _amount);

        IERC20(DAI).approve(address(geistLender), _amount);
        IERC20(DAI).approve(address(this), _amount);


        deposit(DAI, _amount);

        geistLender.setUserUseReserveAsCollateral(DAI, true);

        borrow(DAI,_borrowME);
    }

    function withdraw(
        address _asset,
        uint256 _amount
    ) internal returns (uint256){
        uint256 amountReturned = geistLender.withdraw(_asset, _amount, address(this));
    }

    function borrow(
        address _asset,
        uint256 _amount
    ) internal {
        geistLender.borrow(_asset, _amount, 2, 0, address(this));
    }

    function repay(
        address _asset,
        uint256 _amount
    ) internal returns (uint256){
        uint256 amountRepayed = geistLender.repay(_asset, _amount, 2, address(this));
        return amountRepayed;
    }
}