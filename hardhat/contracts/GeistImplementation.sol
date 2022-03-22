// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./interfaces/IERC20.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/ISwapImplementation.sol";

contract GeistImplementation {

    ILendingPool geistLender = ILendingPool(0x9FAD24f572045c7869117160A571B2e50b10d068);

    address DAI = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;
    address WETH = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;


    function leverageLong(address _asset, address _swapper, uint256 _initialCollateralAmount) external returns (uint256, uint256) {
           uint256 a;uint256 c;

        IERC20(_asset).transferFrom(msg.sender, address(this), _initialCollateralAmount);
        IERC20(_asset).approve(address(geistLender), _initialCollateralAmount);

        geistLender.deposit(_asset, _initialCollateralAmount, address(this), 0);

        geistLender.setUserUseReserveAsCollateral(_asset, true);

        uint256 nextBorrow = _initialCollateralAmount;
        uint256 totalBorrow;
        uint256 totalCollateral = _initialCollateralAmount;
        // After 3 loops law of diminishing returns really kills you
        for(uint i = 0; i < 2; i++){
            uint borrowAmount;
            if( i!=0 ){
                borrowAmount = (nextBorrow * uint256(75)/ 100) ;
            }else{
                borrowAmount = (nextBorrow * uint256(80)/ 100) ;
            }
            (a,,c,,,) = geistLender.getUserAccountData(address(this));

            borrow(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E, borrowAmount);
            totalBorrow += borrowAmount;

            // (address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to
            IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E).approve(address(_swapper), borrowAmount);
            IERC20(_asset).approve(address(_swapper), borrowAmount);


            uint256 amtBeforeSwap = IERC20(_asset).balanceOf(address(this));

            swapImplementation(_swapper).Swap(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E, _asset, borrowAmount, 0, address(this));

            uint256 tokensBought = IERC20(_asset).balanceOf(address(this)) - amtBeforeSwap;



            uint256 nextBorrow = tokensBought;
            // Re-approving each deposit sucks, but is signficiantly safer
            IERC20(_asset).approve(address(geistLender), tokensBought);
            deposit(_asset, tokensBought);
            totalCollateral += tokensBought;
        }
        
        return (totalBorrow, totalCollateral);
        
    }

    function leverageShort(address _asset, address _swapper, uint256 _initialCollateralAmount, uint256 _initialBorrowAmount) external returns (uint256, uint256) {
        IERC20(DAI).transferFrom(msg.sender, address(this), _initialCollateralAmount);
        IERC20(DAI).approve(address(geistLender), _initialCollateralAmount);
        
        

        deposit(DAI, _initialCollateralAmount);
        geistLender.setUserUseReserveAsCollateral(DAI, true);
        uint256 nextBorrow = _initialBorrowAmount;
        uint256 totalBorrow;
        uint256 totalCollateral = _initialCollateralAmount;
        // Highly leveraged shorts breaks a lot of things, so I've limited it for now


        uint256 borrowAmount = (nextBorrow /2) ;
        borrow(_asset, borrowAmount);
        totalBorrow += borrowAmount;

        uint256 amtBeforeSwap = IERC20(DAI).balanceOf(address(this));

        IERC20(_asset).approve(_swapper, borrowAmount);
        swapImplementation(_swapper).Swap(_asset,DAI,borrowAmount, 1, address(this));

        uint256 tokensBought = IERC20(_asset).balanceOf(address(this)) - amtBeforeSwap;

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
        geistLender.deposit(_asset, _amount, address(this), 0);

    }

    function depositMoney(uint256 _amount, address a) external { //deposit and Borrow

        IERC20(a).transferFrom(msg.sender, address(this), _amount);
        IERC20(a).approve(address(geistLender), _amount);

        geistLender.deposit(a, _amount, address(this), 1);
        geistLender.setUserUseReserveAsCollateral(a, true);
        // uint256 borrowAmount = (_amount /2) ;
        // geistLender.borrow(DAI, borrowAmount, 2, 0, address(this));

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

    function getContractHealth() external view returns(uint256, uint256, uint256) {
        (uint256 a, uint256 b ,uint256 c, , , )= geistLender.getUserAccountData(address(this));
        return (a,b,c);
    }    
}
