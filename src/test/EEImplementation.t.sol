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

interface CheatCodes {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
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

        // DInterst Pool
        daiDInterestPool = DInterest(0x89242F3205a21444aF589aF94a3216b13768630E); // This Should Be DAI Via Scream Pool: Default - 0xa78276C04D8d807FeB8271fE123C1f94c08A414d

        // Instantiate Contracts
        testManager = new PhantasmManager();
        testEEIntegration = new EEIntegration(address(testManager));

    }

    function testEEImplementation() public {
        daiWhaleDepositor.call{value: 5 ether}("");
        daiWhaleFunder.call{value: 5 ether}("");

        uint256 daiAmountIn = 1000 * 10**daiDecimals;
        uint64 maturationTimestamp = uint64(block.timestamp + 10000 seconds);


        // Test Making Deposit
        emit log("Starting Process of Making Deposit");
        cheats.startPrank(0xA9497FD9D1dD0d00DE1Bf988E0e36794848900F9);

        uint depositorOpeningBalanceDai = DAI.balanceOf(daiWhaleDepositor);
        emit log_named_uint("DAI Balance Before Deposit", depositorOpeningBalanceDai);

        (uint64 depositId, uint256 depositInterestAmount) = testEEIntegration.makeDeposit(address(daiDInterestPool), daiAmountIn, maturationTimestamp);

        uint depositorBalanceAfterDepositDai = DAI.balanceOf(daiWhaleDepositor);
        emit log_named_uint("DAI Balance After Deposit", depositorBalanceAfterDepositDai);

        assertEq(depositorOpeningBalanceDai, depositorBalanceAfterDepositDai + daiAmountIn);

        uint64 depositMaturationTimestamp = daiDInterestPool.getDeposit(depositId).maturationTimestamp;
        uint64 depositInitialFundingId = daiDInterestPool.getDeposit(depositId).fundingID;
                
        assertEq(depositMaturationTimestamp, maturationTimestamp);
        assertEq(depositInitialFundingId, 0); // Returns as uint64 => Might Need to Be uint64(0)

        cheats.stopPrank();




        // Test Funding Deposit (Buying Yield Tokens)
        emit log("Starting Process of Buying Available Yield Tokens");
        cheats.startPrank(daiWhaleFunder);

        uint256 funderOpeningBalanceDai = DAI.balanceOf(msg.sender);
        emit log_named_uint("DAI Balance Before Funding: ", funderOpeningBalanceDai);

        // fundingMultiTokens might be a uint64 (problem with the EEImplementation)
        (uint64 fundingId, uint256 fundingMultitokensMinted, uint256 actualFundAmount, uint256 principalFunded) = testEEIntegration.buyYieldTokens(address(daiDInterestPool), depositId, depositInterestAmount);

        uint funderBalanceAfterFundingDai = DAI.balanceOf(msg.sender);
        emit log_named_uint("DAI Balance After Funding: ", funderBalanceAfterFundingDai);

        assertEq(funderOpeningBalanceDai, funderBalanceAfterFundingDai + depositInterestAmount);

        uint64 fundedDepositId = daiDInterestPool.getFunding(fundingId).depositID;

        assertEq(fundedDepositId, depositId);
        assertEq(principalFunded, 1000 * (10**daiDecimals) /*+ depositInterestAmount*/);




        // Test Collecting Interest on  YT
        uint funderBalanceBeforeCollectionDai = DAI.balanceOf(msg.sender);
        emit log_named_uint("DAI Balance Before Collection", funderBalanceBeforeCollectionDai);

        uint interestCollected = testEEIntegration.collectInterest(address(daiDInterestPool), fundingId);
        emit log_named_uint("DAI Collected In Interest", interestCollected);

        uint funderBalanceAfterCollectionDai = DAI.balanceOf(msg.sender);
        emit log_named_uint("DAI Balance After Collection", funderBalanceAfterCollectionDai);

        assertEq(funderBalanceBeforeCollectionDai, funderBalanceAfterCollectionDai - interestCollected);
        emit log("User's Balance After Interest Collection is The Before Balance + Interest Amount.");
        // assertEq(interestCollected, expectedInterest)

        cheats.stopPrank();
    }
}


