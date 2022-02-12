// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import {DInterest} from "./IDinterest.sol";

interface DInterestLens {
    function withdrawableAmountOfDeposit(DInterest pool, uint64 depositID, uint256 virtualTokenAmount) external view returns (uint256 withdrawableAmount, uint256 feeAmount);
    function accruedInterestOfFunding(DInterest pool, uint64 fundingID) external returns (uint256 fundingInterestAmount);
    function fundingIsActive(DInterest pool, uint64 fundingID) external view returns (bool);
    function totalInterestOwedToFunders(DInterest pool) external returns (uint256 interestOwed);
    function surplusOfDeposit(DInterest pool, uint64 depositID) external returns (bool isNegative, uint256 surplusAmount);
    function rawSurplusOfDeposit(DInterest pool, uint64 depositID) external returns (bool isNegative, uint256 surplusAmount);
}