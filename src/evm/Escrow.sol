// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Escrow
 * @dev This contract implements an escrow mechanism with basic security and functionality, controlled by the owner.
 */
contract Escrow is ReentrancyGuard, Ownable {

    event Deposited(address indexed sender, uint256 amount);
    event Withdrawn(address indexed beneficiary, uint256 amount);

    uint256 public balance;

    constructor(address owner) Ownable(owner) {}

    /**
     * @dev Deposit funds into the escrow.
     */
    function deposit() 
        external 
        onlyOwner 
        payable 
    {
        balance += msg.value; // Use direct addition for uint256
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw funds from the escrow. Only the owner can initiate withdrawals.
     * @param beneficiary The address that will receive the withdrawn funds.
     * @param amount The amount of funds to withdraw.
     */
    function withdraw(address payable beneficiary, uint256 amount)
        external
        nonReentrant
        onlyOwner
    {
        require(amount <= balance, "Insufficient balance");
        balance -= amount; // Use direct subtraction for uint256
        beneficiary.transfer(amount);
        emit Withdrawn(beneficiary, amount);
    }
}