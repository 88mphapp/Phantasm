// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import {EEIntegration} from "../EEImplementation.sol";
import {PhantasmManager} from "../PhantasmManager.sol";
import {DInterest} from "../interfaces/IDinterest.sol";
import "./utils/console.sol";
import "../../lib/ds-test/src/test.sol";
import {SpookySwapper} from "../SpookySwap.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {GeistImplementation} from "../geistImplementation.sol";
import {AaveImplementation} from "../AaveLenderImplementation.sol";
import "../interfaces/IAave.sol";
import {DInterestLens} from "../interfaces/IDInterestLens.sol";

interface CheatCodes {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function warp(uint256) external;
}

contract EEIntegrationTest is DSTest{
    // Initialize Variables
    IERC20 DAI;
    IERC20 WFTM;
    uint daiDecimals;
    uint wftmDecimals;
    address daiWhaleDepositor;
    address wftmWhaleDepositor;
    address daiWhaleFunder;
    address wftmWhaleFunder;
    PhantasmManager testManager;
    EEIntegration testEEIntegration;
    DInterest daiDInterestPool;
    DInterestLens dInterestLens;
    CheatCodes cheats;

    struct Deposit {
        uint256 virtualTokenTotalSupply; // depositAmount + interestAmount, behaves like a zero coupon bond
        uint256 interestRate; // interestAmount = interestRate * depositAmount
        uint256 feeRate; // feeAmount = feeRate * depositAmount
        uint256 averageRecordedIncomeIndex; // Average income index at time of deposit, used for computing deposit surplus
        uint64 maturationTimestamp; // Unix timestamp after which the deposit may be withdrawn, in seconds
        uint64 fundingID; // The ID of the associated Funding struct. 0 if not funded.
    }

    struct Funding {
        uint64 depositID; // The ID of the associated Deposit struct.
        uint64 lastInterestPayoutTimestamp; // Unix timestamp of the most recent interest payout, in seconds
        uint256 recordedMoneyMarketIncomeIndex; // the income index at the last update (creation or withdrawal)
        uint256 principalPerToken; // The amount of stablecoins that's earning interest for you per funding token you own. Scaled to 18 decimals regardless of stablecoin decimals.
    }

    function setUp() public {

        // Cheatcodes
        cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        // Token Addresses
        DAI = IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
        WFTM = IERC20(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);

        // Decimals
        daiDecimals = 18;
        wftmDecimals = 18;

        // Whale Addresses
        daiWhaleDepositor = 0xA9497FD9D1dD0d00DE1Bf988E0e36794848900F9;
        wftmWhaleDepositor = 0x93C08a3168fC469F3fC165cd3A471D19a37ca19e;

        daiWhaleFunder = 0x1a8A0255e8B0ED7C596D236bf28D57Ff3978899b;
        wftmWhaleFunder = 0xAcEDaB2752882455982E33CF26094284ceE8B6ea;

        // DInterst Pool 0x89242F3205a21444aF589aF94a3216b13768630E
        daiDInterestPool = DInterest(0xa78276C04D8d807FeB8271fE123C1f94c08A414d); // This Should Be DAI Via Scream Pool: Default - 0xa78276C04D8d807FeB8271fE123C1f94c08A414d
        dInterestLens = DInterestLens(0x162083f8096f54d68c6a5f8E86adB400FfC4b201);

        // Instantiate Contracts
        testManager = new PhantasmManager();
        testEEIntegration = new EEIntegration(address(testManager));
    }

    function testEEImplementation() public {
        emit log("Starting Process of Making Deposit");

        // Fund The EEImplementation Contract
        cheats.startPrank(0xA9497FD9D1dD0d00DE1Bf988E0e36794848900F9);
        DAI.transfer(address(testEEIntegration), 100000 * (10**18));
        cheats.stopPrank();

        // Test Making Deposit
        uint256 daiAmountIn = 1000 * 10**daiDecimals;
        uint64 maturationTimestamp = 1647804453;

        uint256 depositorOpeningBalanceDai = DAI.balanceOf(address(testEEIntegration));
        (uint64 depositId,) = testEEIntegration.makeDeposit(address(daiDInterestPool), daiAmountIn, maturationTimestamp);
        uint depositorBalanceAfterDepositDai = DAI.balanceOf(address(testEEIntegration));

        assertEq(depositorOpeningBalanceDai, depositorBalanceAfterDepositDai + daiAmountIn);

        uint64 depositMaturationTimestamp = daiDInterestPool.getDeposit(depositId).maturationTimestamp;
        uint64 depositInitialFundingId = daiDInterestPool.getDeposit(depositId).fundingID;
                
        assertEq(depositMaturationTimestamp, maturationTimestamp);
        assertEq(depositInitialFundingId, 0);



        // Test Funding Deposit (Buying Yield Tokens)
        emit log("Starting Process of Buying Available Yield Tokens");

        uint256 funderOpeningBalanceDai = DAI.balanceOf(address(testEEIntegration));

        (,uint256 surplus) = dInterestLens.surplusOfDeposit(daiDInterestPool, depositId);

        uint256 fundAmountIn = surplus * 100;

        // Amount In is Capped to Equal actualFundAmount
        (uint64 fundingId,, uint256 actualFundAmount,) = testEEIntegration.buyYieldTokens(address(daiDInterestPool), depositId, fundAmountIn);
        
        // Assert A > B
        assertGt(fundAmountIn, actualFundAmount);

        uint funderBalanceAfterFundingDai = DAI.balanceOf(address(testEEIntegration));

        assertEq(funderOpeningBalanceDai, funderBalanceAfterFundingDai + actualFundAmount);

        uint64 fundedDepositId = daiDInterestPool.getFunding(fundingId).depositID;

        assertEq(fundedDepositId, depositId);
        assertTrue(dInterestLens.fundingIsActive(daiDInterestPool, fundingId));





        // Test Collecting Interest on  YT
        emit log("Starting Process of Collecting Interest On Yield Tokens");
        cheats.warp(block.timestamp + 2419200);

        uint funderBalanceBeforeCollectionDai = DAI.balanceOf(address(testEEIntegration));
        uint interestCollected = testEEIntegration.collectInterest(address(daiDInterestPool), fundingId);
        uint funderBalanceAfterCollectionDai = DAI.balanceOf(address(testEEIntegration));

        assertEq(funderBalanceBeforeCollectionDai, funderBalanceAfterCollectionDai - interestCollected);
    }
}