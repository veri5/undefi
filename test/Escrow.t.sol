// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "../src/evm/Escrow.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract ReentrancyAttack {   
    // Instance of the Escrow contract
    Escrow escrow;

    // Amount for testing deposits and withdrawals
    uint256 amount;

    /**
     * @dev Constructor to initialize the ReentrancyAttack contract.
     * @param escrowAddress The address of the Escrow contract to attack.
     */
    constructor(address escrowAddress) {
        // Initialize the Escrow instance and the testing amount
        escrow = Escrow(escrowAddress);
        amount = 5 ether;
    }

    /**
     * @dev Receive function called when Ether is sent to this contract.
     * If the Escrow's balance is sufficient, initiate a withdrawal.
     */
    receive() external payable {
        if (address(escrow).balance >= amount) {
            escrow.withdraw(payable(address(this)), amount);
        }
    }

    /**
     * @dev External function to trigger a reentrant attack by calling the withdraw function of the Escrow contract.
     */
    function attack() external {
        escrow.withdraw(payable(address(this)), amount);
    }
}

/**
 * @title EscrowTest Contract
 * @dev Contract designed for testing the Escrow contract functionality.
 */
contract EscrowTest is Test {
    // Addresses for testing purposes
    address owner;
    address payable beneficiary;
    address payable unauthorized;
    
    // Instance of the Escrow contract
    Escrow escrow;
    
    // Amount for testing deposits and withdrawals
    uint256 amount;

    /**
     * @dev Sets up initial test conditions.
     */
    function setUp() public {
        // Set up addresses, Escrow instance, and testing amount
        owner = address(this);
        beneficiary = payable(makeAddr("beneficiary"));
        unauthorized = payable(makeAddr("unauthorized"));
        escrow = new Escrow(owner);
        amount = 100 ether;
    }

    /**
     * @dev Tests the deposit function.
     */
    function testDeposit() public {
        // Emits an event for the expected deposit
        vm.expectEmit(false, false, false, true, address(escrow));
        emit Escrow.Deposited(amount);

        // Calls the deposit function
        escrow.deposit{value: amount}();

        // Asserts the correctness of the escrow balance
        assertEq(escrow.balance(), amount, "Deposit: Incorrect escrow balance");
    }

    /**
     * @dev Tests the withdraw function.
     */
    function testWithdraw() public {
        // Deposits an amount into the escrow for testing
        escrow.deposit{value: amount}();
        
        // Emits an event for the expected withdrawal
        vm.expectEmit(true, false, false, true, address(escrow));
        emit Escrow.Withdrawn(beneficiary, amount);

        // Calls the withdraw function
        escrow.withdraw(beneficiary, amount);

        // Asserts the correctness of the escrow balance after withdrawal
        assertEq(escrow.balance(), 0, "Withdraw: Incorrect escrow balance after withdrawal");

        // Asserts that the beneficiary received the correct amount
        assertEq(address(beneficiary).balance, amount, "Withdraw: Beneficiary did not receive funds");
    }

    /**
     * @dev Tests the pausable functionality of withdrawal.
     */
    function testPausedWithdrawal() public {
        // Pause the Escrow contract
        escrow.pause();

        // Expect a revert when calling the withdraw function during the paused state
        vm.expectRevert();

        // Calls the withdraw function (expecting revert due to pausing)
        escrow.withdraw(beneficiary, amount);
    }

    /**
     * @dev Tests the combined functionality of onlyOwner and pausable for the withdraw function.
     */
    function testOnlyOwnerPausableWithdraw() public {
        // Expect a revert when an unauthorized address attempts to call the pause function
        vm.expectRevert();

        // Prank function simulates an unauthorized address attempting to call the pause function
        vm.prank(unauthorized);

        // Unauthorized address attempts to call the pause function
        escrow.pause();
    }

    /**
    * @dev Tests the reentrancy guard for the withdraw function.
    */
    function testReentrancyGuard() public {
        // Deposit funds for testing
        escrow.deposit{value: amount}();

        // Create an instance of the ReentrancyAttack contract
        ReentrancyAttack attackContract = new ReentrancyAttack(address(escrow));

        // Expect a revert due to the reentrancy guard
        vm.expectRevert("Transfer failed");

        // Perform the reentrant attack
        attackContract.attack();
    }
}
