// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import "../src/evm/TransferTracker.sol";

contract TransferTrackerTest is Test {
  TransferTracker transferTracker;
  address payable escrow;
  address payable beneficiary;

  event FundsDeposited(address indexed escrow, uint256 amount);
  event FundsWithdrawn(address indexed beneficiary, uint256 amount);
  
  function setUp() public {
      transferTracker = new TransferTracker();
      escrow = transferTracker.escrow();
      beneficiary = payable(makeAddr("beneficiary"));
  }

  function testDeposit() public {
    uint256 initialBalance = address(transferTracker).balance;
    uint256 amount = 100 ether;

    transferTracker.deposit{value: amount}();

    assertEq(address(transferTracker).balance, initialBalance + amount, "Incorrect deposit amount");
  }

  function testWithdraw() public {
    uint256 initialBalance = address(transferTracker).balance;
    uint256 amount = 100 ether;

    transferTracker.deposit{value: amount}();
    transferTracker.withdraw(amount, beneficiary);

    assertEq(address(transferTracker).balance, initialBalance, "Withdrawal not successful");
    assertEq(address(beneficiary).balance, amount, "Beneficiary did not receive funds");
  }

  function testDepositEvent() public {
    uint256 amount = 100 ether;

    vm.expectEmit(true, false, false, true, address(transferTracker));
    // We emit the event we expect to see.
    emit FundsDeposited(escrow, amount);

    transferTracker.deposit{value: amount}();
  }

  function testWithdrawEvent() public {
    uint256 amount = 100 ether;
    transferTracker.deposit{value: amount}();

    vm.expectEmit(true, false, false, true, address(transferTracker));
    // We emit the event we expect to see.
    emit FundsWithdrawn(beneficiary, amount);

    transferTracker.withdraw(amount, beneficiary);
  }

  function testOnlyEscrowDeposit() public {
    uint256 amount = 100 ether;
    vm.expectRevert("Only escrow can deposit");

    vm.startPrank(msg.sender);
    transferTracker.deposit{value: amount}();
    vm.stopPrank();
  }

  function testOnlyEscrowWithdraw() public {
    uint256 amount = 100 ether;
    transferTracker.deposit{value: amount}();

    vm.expectRevert("Only escrow can withdraw");

    vm.startPrank(msg.sender);
    transferTracker.withdraw(amount, beneficiary);
    vm.stopPrank();
  }
}