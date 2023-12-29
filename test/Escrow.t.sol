// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "../src/evm/Escrow.sol";

/**
 * @title EscrowTest Contract
 * @dev Contract designed for testing the Escrow contract functionality.
 */
contract EscrowTest is Test {
    // Addresses for testing purposes
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
        beneficiary = payable(makeAddr("beneficiary"));
        escrow = new Escrow();
        amount = 100 ether;
    }

    /**
     * @dev Tests the deposit function.
     */
    function testDeposit() public {
        // Emits an event for expected deposit
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
        
        // Emits an event for expected withdrawal
        vm.expectEmit(true, false, false, true, address(escrow));
        emit Escrow.Withdrawn(beneficiary, amount);

        // Calls the withdraw function
        escrow.withdraw(beneficiary, amount);

        // Asserts the correctness of the escrow balance after withdrawal
        assertEq(escrow.balance(), 0, "Withdraw: Incorrect escrow balance after withdrawal");

        // Asserts that the beneficiary received the correct amount
        assertEq(address(beneficiary).balance, amount, "Withdraw: Beneficiary did not receive funds");
    }
}
