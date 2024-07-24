//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
        FundMe fundme;
        address USER = makeAddr("user");

        uint256 constant SEND_VALUE = 0.1 ether;
        uint256 constant STARTING_BALANCE = 10 ether;


    function setUp() external{

        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSDIsFive() public{
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public{
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public{
        assertEq(fundme.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        //hey next line should revert
        fundme.fund();
    }
    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER);

        fundme.fund{value:SEND_VALUE}();

        uint256 amountFunded = fundme.getAddressAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);

        fundme.fund{value:SEND_VALUE}();

        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded(){
        vm.prank(USER);

        fundme.fund{value:SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();

    }
    function testWithdrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        //Act

        vm.prank(fundme.getOwner());
        fundme.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;

        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);
    }
    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders =10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex;i<numberOfFunders;i++){

            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }

         uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        assertEq(address(fundme).balance, 0);
        assert(startingFundMeBalance+startingOwnerBalance == fundme.getOwner().balance);
    }
    function testWithdrawFromMultipleFundersCheaper() public funded{
        uint160 numberOfFunders =10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex;i<numberOfFunders;i++){

            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }

         uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.cheaperWithdraw();

        assertEq(address(fundme).balance, 0);
        assert(startingFundMeBalance+startingOwnerBalance == fundme.getOwner().balance);
    }
}