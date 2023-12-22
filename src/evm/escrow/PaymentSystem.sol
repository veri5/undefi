// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./PullPayment.sol";

/**
 * @title PaymentSystem
 * @dev A smart contract for managing payments and allowing payees to collect their payments.
 */
contract PaymentSystem is PullPayment {

  mapping(address => uint256) private paymentsDue;

  event PaymentInitiated(address indexed payee, uint256 amount);
  event PaymentCollected(address indexed payee, uint256 amount);

  /**
   * @dev Initiates a payment from the sender to the specified payee.
   * @param payee The address of the payee.
   * @param amount The amount of the payment.
   */
  function initiatePayment(address payable payee, uint256 amount) external payable {
    require(msg.value >= amount, "Insufficient funds sent for payment");

    paymentsDue[payee] += amount;

    emit PaymentInitiated(payee, amount);

    _asyncTransfer(payee, amount);
  }

  /**
   * @dev Allows payees to collect their payments.
   */
  function collectPayment() external {
    uint256 owedAmount = paymentsDue[msg.sender];
    require(owedAmount > 0, "No payments due to this payee");

    paymentsDue[msg.sender] = 0;

    emit PaymentCollected(msg.sender, owedAmount);

    withdrawPayments(payable(msg.sender));
  }
}
