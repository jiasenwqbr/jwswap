// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface INFT {
    function mint(address receiver) external returns (uint256);
}

interface IRecommendation {
    function getUserInfo(address user) external view returns (
        address referrer,
        uint256 registrationTime,
        address[] memory directReferrals,
        address[] memory referralChain
    );
}