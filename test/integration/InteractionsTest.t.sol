//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from"../../script/Interactions.s.sol";

contract InteractionsTest is Test{
    FundMe fundme;
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public{
        FundFundMe fundFundMe = new FundFundMe();
        
        // vm.prank(USER);
        // vm.deal(USER)
        fundFundMe.fundFundMe(address(fundme));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        assert(address(fundme).balance == 0);


        // address funder = fundme.getFunder(0);
        // assertEq(funder, USER);
    }

}