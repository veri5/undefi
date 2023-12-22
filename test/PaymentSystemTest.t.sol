// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import "../src/evm/escrow/PaymentSystem.sol";

contract PaymentSystemTest is Test {
  PaymentSystem paymentSystem;
  address payable payee;
  uint256 amount = 10 ether;

  event PaymentInitiated(address indexed payee, uint256 amount);
  event PaymentCollected(address indexed payee, uint256 amount);

  function setUp() public {
    paymentSystem = new PaymentSystem();
    payee = payable(makeAddr("payee"));
  }

  function testInitiatePayment() public {
    (bool success, ) = address(paymentSystem).call{value: amount}(
        abi.encodeWithSignature("initiatePayment(address,uint256)", payee, amount)
    );

    assertTrue(success, "Initiate payment should be successful");
  }

  function testCollectPayment() public {
    paymentSystem.initiatePayment{value: amount}(payee, amount);

    vm.prank(payee);
    (bool success, ) = address(paymentSystem).call(
        abi.encodeWithSignature("collectPayment()")
    );

    assertTrue(success, "Collect payment should be successful");
  }

  function testInitiatePaymentEvent() public {
    vm.expectEmit(true, false, false, true, address(paymentSystem));
    // We emit the event we expect to see.
    emit PaymentInitiated(payee, amount);

    paymentSystem.initiatePayment{value: amount}(payee, amount);
  }

  function testCollectPaymentEvent() public {
    paymentSystem.initiatePayment{value: amount}(payee, amount);

    vm.expectEmit(true, false, false, true, address(paymentSystem));
    // We emit the event we expect to see.
    emit PaymentCollected(payee, amount);

    vm.prank(payee);
    paymentSystem.collectPayment();
  }
}