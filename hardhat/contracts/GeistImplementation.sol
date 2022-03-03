// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;


import "./interfaces/IERC20.sol";
import "./interfaces/ILendingPool.sol";

contract GeistImplementation {

    ILendingPool geistLender = ILendingPool(0x9FAD24f572045c7869117160A571B2e50b10d068);

    address DAI = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;

    function getValue() external view returns (uint256){
        (uint256 a, ,, , , ) = geistLender.getUserAccountData(address(this));
        return a;
    }

    function getBalance() external view returns (uint256){
        uint256 a = IERC20(DAI).balanceOf(address(this));
        return a;
    }
    
    function deposit(
    ) public {   
        uint256 _amount = 100 * 1e18;

        IERC20(DAI).approve(address(geistLender), _amount);
        geistLender.deposit(DAI, _amount, address(this), 0);

    }



    function depositMoney(uint256 _amount, uint256 _borrowME) public { //deposit and Borrow

        IERC20(DAI).transferFrom(msg.sender, address(this), _amount);


        IERC20(DAI).approve(address(geistLender), _amount);

        geistLender.deposit(DAI, _amount, msg.sender, 1);

        geistLender.setUserUseReserveAsCollateral(DAI, true);

        geistLender.borrow(DAI, _borrowME, 2, 0, address(this));

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
