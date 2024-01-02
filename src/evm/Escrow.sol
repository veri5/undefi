// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Escrow
 * @dev Implements an escrow mechanism with basic security and functionality.
 */
contract Escrow is ReentrancyGuard, Pausable, Ownable {
    // Event emitted when funds are deposited into the escrow
    event Deposited(uint256 amount);
    // Event emitted when funds are withdrawn from the escrow
    event Withdrawn(address indexed beneficiary, uint256 amount);

    // Current balance in the escrow
    uint256 public balance;

    /**
     * @dev Constructor to set the initial owner.
     * @param initialOwner The initial owner of the contract.
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Deposit funds into the escrow.
     */
    function deposit() external payable whenNotPaused nonReentrant {
        // Increase the balance by the deposited amount
        balance += msg.value;
        // Emit event for the deposit
        emit Deposited(msg.value);
    }

    /**
     * @dev Withdraw funds from the escrow.
     * @param beneficiary The address that will receive the withdrawn funds.
     * @param amount The amount of funds to withdraw.
     */
    function withdraw(address payable beneficiary, uint256 amount) external whenNotPaused nonReentrant {
        // Check if the amount to withdraw does not exceed the balance
        require(amount <= balance, "Insufficient balance");
        // Decrease the balance by the withdrawn amount
        balance -= amount;
        // Transfer the funds to the beneficiary
        (bool success, ) = beneficiary.call{value: amount}("");
        require(success, "Transfer failed");
        // Emit event for the withdrawal
        emit Withdrawn(beneficiary, amount);
    }

    /**
     * @dev Function to pause the contract.
     * Can only be called by the owner.
     */
    function pause() external onlyOwner {
        // Call the internal function to pause the contract
        _pause();
    }

    /**
     * @dev Function to unpause the contract.
     * Can only be called by the owner.
     */
    function unpause() external onlyOwner {
        // Call the internal function to unpause the contract
        _unpause();
    }
}