// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import "../src/escrow/Escrow.sol";

contract EscrowTest is Test {
  Escrow escrow;
  address payable payee;
  uint256 amount = 100 ether;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  function setUp() public {
      escrow = new Escrow();
      payee = payable(makeAddr("payee"));
  }

  function testDeposit() public {
    escrow.deposit{value: amount}(payee);

    assertEq(escrow.depositsOf(payee), amount, "Incorrect deposit amount");
  }

  function testWithdraw() public {
    escrow.deposit{value: amount}(payee);
    escrow.withdraw(payee);

    assertEq(escrow.depositsOf(payee), 0, "Withdrawal not successful");
  }

  function testDepositEvent() public {
    vm.expectEmit(true, false, false, true, address(escrow));
    // We emit the event we expect to see.
    emit Deposited(payee, amount);

    escrow.deposit{value: amount}(payee);
  }

  function testWithdrawEvent() public {
    escrow.deposit{value: amount}(payee);

    vm.expectEmit(true, false, false, true, address(escrow));
    // We emit the event we expect to see.
    emit Withdrawn(payee, amount);

    escrow.withdraw(payee);
  }

  function testOnlyPrimaryDeposit() public {
    vm.expectRevert("Caller is not the primary account");

    vm.startPrank(msg.sender);
    escrow.deposit{value: amount}(payee);
    vm.stopPrank();
  }

  function testOnlyPrimaryWithdraw() public {
    escrow.deposit{value: amount}(payee);

    vm.expectRevert("Caller is not the primary account");

    vm.startPrank(msg.sender);
    escrow.withdraw(payee);
    vm.stopPrank();
  }
}