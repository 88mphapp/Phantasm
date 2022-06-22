// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

// Some interfaces are needed here
import "./interfaces/IERC20.sol";
import './interfaces/ISwapImplementation.sol';
import "./test/utils/console.sol";

interface ILender {
    function leverageLong(address _asset, address _swapper, uint256 _initialCollateralAmount) external returns (uint256, uint256);
    function leverageShort(address _asset, address _swapper, uint256 _initialCollateralAmount, uint256 _initialBorrowAmount, uint256 _borrowFactor) external returns (uint256, uint256);
    function closePosition(address _debtAsset, address _asset, address _swapper, uint256 _debtOwed, uint256 _totalCollateral, address sender) external;
}

interface IBond {
    function collectAllInterest(address _token) external returns (uint256 _amountCollected);
    function findAndBuyYieldTokens(address _token, uint256 _amount) external returns (uint256 _amountSpent);
    function buyYieldTokens (address _assetPool, uint64 _depositId, uint256 _stableInAmount) external returns (uint64 _fundingID, uint256 fundingMultitokensMinted, uint256 actualFundAmount, uint256 principalFunded);
}
contract PhantasmManager {

    address private owner;
    address private immutable DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private immutable DAIDinterest = 0xa78276C04D8d807FeB8271fE123C1f94c08A414d;

    struct Position {
        bool    isLong;
        bool    isInsulated;
        address asset;
        address stablecoin;
        uint256 debtOwed;
        uint256 totalCollateral;
    }
    // Ledger holds all token ids to tokens
    mapping(address => Position) private positionLedger;
    uint256 counter = 0;

    address lenderImplementation;
    address bondImplementation;
    address swapImplementation;

    constructor(address _lenderImplementation, address _bondImplementation, address _swapImplementation ) {
        lenderImplementation = _lenderImplementation;
        bondImplementation = _bondImplementation;
        swapImplementation = _swapImplementation;
    }

    /*
            __      __         _ _     ______                _   _                 
            \ \    / /        | | |   |  ____|              | | (_)                
            \ \  / /_ _ _   _| | |_  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
            \ \/ / _` | | | | | __| |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
            \  / (_| | |_| | | |_  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
            \/ \__,_|\__,_|_|\__| |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
                                                                                
                                                                                
    */
    mapping(uint => address) public ownership;

    function addPosition(Position memory _newPosition) internal returns(uint256) {
        counter++;
        //Push Position to ledger
        ownership[counter] = msg.sender;
        
        return counter;
    }
    
    // function removePosition(address _tokenID) internal {
    //     ownership[_tokenID] = address(this); // Remove ownership from Positon

    //     delete positionLedger[_tokenID];
    // }
    // function viewPosition(address user) public view returns(Position memory) {
    //     return positionLedger[user];
    // }


    /*
         _                                    _             
        | |                                  (_)            
        | |     _____   _____ _ __ __ _  __ _ _ _ __   __ _ 
        | |    / _ \ \ / / _ \ '__/ _` |/ _` | | '_ \ / _` |
        | |___|  __/\ V /  __/ | | (_| | (_| | | | | | (_| |
        |______\___| \_/ \___|_|  \__,_|\__, |_|_| |_|\__, |
                                        __/ |         __/ |
                                        |___/         |___/ 
    */

    function openLongPositionNFT(
        address _longToken,
        uint256 _borrowFactor,
        uint256 _assetAmount
) public returns (uint256) {

        IERC20(_longToken).transferFrom(msg.sender, address(this), _assetAmount);
        IERC20(_longToken).approve(lenderImplementation, _assetAmount);

        (uint256 totalDebtETH, uint256 totalCollateral) = ILender(lenderImplementation).leverageLong(_longToken, swapImplementation, _assetAmount);

        Position memory createdPosition;

        createdPosition.isLong = true;
        createdPosition.isInsulated = false;
        createdPosition.asset = _longToken;
        createdPosition.debtOwed = totalDebtETH;
        createdPosition.stablecoin = DAI; // DAI for now
        createdPosition.totalCollateral = totalCollateral;

        positionLedger[msg.sender] = createdPosition;

        console.log("totalCollateral ", totalCollateral);
        console.log("totalDebtETH ", totalDebtETH);


        return 2;
    }

    function closeLongPosition(address _tokenID, address _swapImplementation) public {
            require(positionLedger[msg.sender].totalCollateral> 0, "You have to own something to get it's value");
            //Position memory liquidateMe = viewPosition(_tokenID);
            //swap(address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to)
            // DAI to repay

            uint256 amountToRepay = 50 + positionLedger[msg.sender].debtOwed;
            uint256 totalCollateral = positionLedger[msg.sender].totalCollateral;
            console.log("amount to repay", amountToRepay);
            console.log("totalCollateral", totalCollateral);

            IERC20(DAI).transferFrom(msg.sender, address(this) , amountToRepay);

            IERC20(DAI).approve(lenderImplementation, amountToRepay);
            ILender(lenderImplementation).closePosition(address(DAI), _tokenID, _swapImplementation, amountToRepay, totalCollateral, msg.sender);

    }

    function openShortPositionNFT(
        address _shortToken,
        uint256 _borrowFactor,
        uint256 _assetAmount,
        uint256 _initialBorrow
        ) public returns (uint256) {
            IERC20(DAI).transferFrom(msg.sender, address(this), _assetAmount);
            IERC20(DAI).approve(lenderImplementation, _assetAmount);
            (uint256 totalBorrow, uint256 totalCollateral) = ILender(lenderImplementation).leverageShort(_shortToken, swapImplementation, _assetAmount, _initialBorrow, _borrowFactor);

            Position memory createdPosition;

            createdPosition.isLong = false;
            createdPosition.isInsulated = false;
            createdPosition.asset = _shortToken;
            createdPosition.debtOwed = totalBorrow;
            createdPosition.stablecoin = DAI; // DAI for now
            createdPosition.totalCollateral = totalCollateral;


            uint256 PositionID = addPosition(createdPosition);
            return PositionID;
        }
        function closeShortPosition(uint256 _tokenID, uint8 _swapImplementation, uint256 _interestAccured) public {
            // require(ownership[_tokenID] == msg.sender, "You have to own something to get it's value");
            // Position memory liquidateMe = viewPosition(_tokenID);
            // //swap(address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to)
            // // DAI to repay
            // uint256 amountToRepay = _interestAccured + liquidateMe.debtOwed;
            // IERC20(liquidateMe.asset).transferFrom(msg.sender, address(this), amountToRepay);
            // IERC20(liquidateMe.asset).approve(lenderImplementation, amountToRepay);
            // ILender(lenderImplementation).closePosition(liquidateMe.asset, DAI, swapImplementation, amountToRepay, liquidateMe.totalCollateral);

    }

/*
    _____                 _       _           _ 
    |_   _|               | |     | |         | |
    | |  _ __  ___ _   _| | __ _| |_ ___  __| |
    | | | '_ \/ __| | | | |/ _` | __/ _ \/ _` |
    _| |_| | | \__ \ |_| | | (_| | ||  __/ (_| |
    |_____|_| |_|___/\__,_|_|\__,_|\__\___|\__,_|
                                              
*/
    function openInsulatedLongPositionNFT(
        address _longToken,
        uint256 _borrowFactor,
        uint256 _assetAmount,
        uint64 _depositId,
        uint256 stableInAmount
) public returns (uint256) {
        //function leverageLong(address _longToken, uint256 _borrowAmount, uint256 _borrowFactor, address _swapImplementation) external;
        // Just to see the functions its actually calling because this part is a bit of a mess
        IERC20(_longToken).transferFrom(msg.sender, address(this), _assetAmount);

        console.log("we");

        // Insure against DAI you will be borrowing
        IERC20(DAI).transferFrom(msg.sender, address(this), stableInAmount);      
        console.log("we");

        IERC20(DAI).approve(bondImplementation, stableInAmount);
        IERC20(DAI).transfer(bondImplementation, stableInAmount);      
                console.log("we");


        IBond(bondImplementation).buyYieldTokens(DAIDinterest, _depositId, stableInAmount);
        console.log("we");

        IERC20(_longToken).approve(lenderImplementation, _assetAmount);

        (uint256 totalBorrow, uint256 totalCollateral) = ILender(lenderImplementation).leverageLong(_longToken, swapImplementation, _assetAmount);
                console.log("we");



        Position memory createdPosition;

        createdPosition.isLong = true;
        createdPosition.isInsulated = true;
        createdPosition.asset = _longToken;
        createdPosition.debtOwed = totalBorrow;
        createdPosition.stablecoin = DAI; // DAI for now
        createdPosition.totalCollateral = totalCollateral;
        //createdPosition.lender = 0;

                console.log("after tranfer 1");

        uint256 PositionID = addPosition(createdPosition);
                        console.log("after tranfer 1");

        return PositionID;
    }

    function closeInsulatedLongPosition(uint256 _tokenID, uint256 _tipFee) public {
        // require(ownership[_tokenID] == msg.sender, "You have to own something to get it's value");
        // // _tipFee is just incase bond doesn't accure exactly the same and you need to give it a lil boost
        //     Position memory liquidateMe = viewPosition(_tokenID);
        //     require(liquidateMe.isInsulated, "Position is not Insulated");
        //     IERC20(DAI).transferFrom(msg.sender, address(this), liquidateMe.debtOwed + _tipFee);
        //     uint256 amountCollected = IBond(bondImplementation).collectAllInterest(liquidateMe.stablecoin);
        //     //swap(address _tokenIn, address _tokenOut, uint _amountIn, uint _amountOutMin, address _to)
        //     // DAI to repay
        //     uint256 amountToRepay = amountCollected + liquidateMe.debtOwed + _tipFee;
        //     IERC20(DAI).approve(lenderImplementation, amountToRepay);
        //     ILender(lenderImplementation).closePosition(DAI, liquidateMe.asset, swapImplementation, amountToRepay, liquidateMe.totalCollateral);
    }

}

