// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Escrow
 * @dev Implements an escrow mechanism with basic security and functionality.
 */
contract Escrow is ReentrancyGuard {
    event Deposited(uint256 amount);
    event Withdrawn(address indexed beneficiary, uint256 amount);

    uint256 public balance;

    /**
     * @dev Deposit funds into the escrow.
     */
    function deposit() external payable {
        balance += msg.value; // Use direct addition for uint256
        emit Deposited(msg.value);
    }

    /**
     * @dev Withdraw funds from the escrow.
     * @param beneficiary The address that will receive the withdrawn funds.
     * @param amount The amount of funds to withdraw.
     */
    function withdraw(address payable beneficiary, uint256 amount) external nonReentrant {
        require(amount <= balance, "Insufficient balance");
        balance -= amount; // Use direct subtraction for uint256
        beneficiary.transfer(amount);
        emit Withdrawn(beneficiary, amount);
    }
}