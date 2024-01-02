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
    event Deposited(uint256 amount);
    event Withdrawn(address indexed beneficiary, uint256 amount);

    uint256 public balance;

    /**
     * @dev Constructor to set the initial owner.
     */
    constructor(address initialOwner) Ownable(initialOwner) {}
    
    /**
     * @dev Deposit funds into the escrow.
     */
    function deposit() external payable whenNotPaused nonReentrant {
        balance += msg.value; // Use direct addition for uint256
        emit Deposited(msg.value);
    }

    /**
     * @dev Withdraw funds from the escrow.
     * @param beneficiary The address that will receive the withdrawn funds.
     * @param amount The amount of funds to withdraw.
     */
    function withdraw(address payable beneficiary, uint256 amount) external whenNotPaused nonReentrant {
        require(amount <= balance, "Insufficient balance");
        balance -= amount; // Use direct subtraction for uint256
        (bool success, ) = beneficiary.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawn(beneficiary, amount);
    }

    /**
     * @dev Function to pause the contract.
     * Can only be called by the owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Function to unpause the contract.
     * Can only be called by the owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}