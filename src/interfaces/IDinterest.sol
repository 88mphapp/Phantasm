// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface DInterest {

    // User deposit data
    // Each deposit has an ID used in the depositNFT, which is equal to its index in `deposits` plus 1
    struct Deposit {
        uint256 virtualTokenTotalSupply; // depositAmount + interestAmount, behaves like a zero coupon bond
        uint256 interestRate; // interestAmount = interestRate * depositAmount
        uint256 feeRate; // feeAmount = feeRate * depositAmount
        uint256 averageRecordedIncomeIndex; // Average income index at time of deposit, used for computing deposit surplus
        uint64 maturationTimestamp; // Unix timestamp after which the deposit may be withdrawn, in seconds
        uint64 fundingID; // The ID of the associated Funding struct. 0 if not funded.
    }

    // fund(uint64 depositID, uint256 fundAmount) → uint64 fundingID
    /*
    @param depositID The deposit whose fixed-rate interest will be funded
    @param fundAmount The amount of fixed-rate interest to fund. If it exceeds surplusOfDeposit(depositID), it will be set to the surplus value instead.
    @param fundingID The ID of the fundingMultitoken the sender received
    */
    struct Funding {
        uint64 depositID; // The ID of the associated Deposit struct.
        uint64 lastInterestPayoutTimestamp; // Unix timestamp of the most recent interest payout, in seconds
        uint256 recordedMoneyMarketIncomeIndex; // the income index at the last update (creation or withdrawal)
        uint256 principalPerToken; // The amount of stablecoins that's earning interest for you per funding token you own. Scaled to 18 decimals regardless of stablecoin decimals.
    }

    function fund(uint64 depositID, uint256 fundAmount) external returns (uint64 fundingID, uint256 fundingMultitokensMinted, uint256 actualFundAmount, uint256 principalFunded);
    function deposit (uint256 depositAmount, uint64 maturationTimestamp) external returns (uint64 depositID, uint256 interestAmount);
    // Monitor deposit events to be emitted to scrape depositIDs

    function getFunding(uint64 fundingID) external view returns (Funding memory);
    function payInterestToFunders(uint64 fundingID) external returns (uint256 interestAmount);
    function depositsLength() external view returns (uint256);
    function getDeposit(uint64 depositID) external view returns (Deposit memory);

    function topupDeposit(uint64 depositID, uint256 depositAmount) external returns (uint256 interestAmount);
    function rolloverDeposit(uint64 depositID, uint64 maturationTimestamp) external returns (uint256 newDepositID, uint256 interestAmount);
    function withdraw(uint64 depositID, uint256 virtualTokenAmount, bool early) external returns (uint256 withdrawnStablecoinAmount);

    // Public Getter Functions
    function calculateInterestAmount(uint256 depositAmount, uint256 depositPeriodInSeconds) external returns (uint256 interestAmount);
    function surplus() external returns (bool isNegative, uint256 surplusAmount);
    function fundingListLength() external view returns (uint256);


}