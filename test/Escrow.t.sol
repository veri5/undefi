// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "../src/evm/Escrow.sol";

/**
 * @title EscrowTest Contract
 * @dev This contract is used for testing the Escrow contract functionality.
 */
contract EscrowTest is Test {
    address payable owner;
    address payable beneficiary;
    Escrow escrow;
    uint256 amount;

    event Deposited(address indexed owner, uint256 amount);
    event Withdrawn(address indexed beneficiary, uint256 amount);

    /**
     * @dev Set up initial test conditions.
     */
    function setUp() public {
        owner = payable(address(this));
        beneficiary = payable(makeAddr("beneficiary"));
        escrow = new Escrow(owner);
        amount = 100 ether;
    }

    /**
     * @dev Test the deposit function.
     */
    function testDeposit() public {
        vm.expectEmit(true, false, false, true, address(escrow));
        emit Deposited(owner, amount);

        escrow.deposit{value: amount}();

        assertEq(escrow.balance(), amount, "Deposit: Incorrect escrow balance");
    }

    /**
     * @dev Test the withdraw function.
     */
    function testWithdraw() public {
        escrow.deposit{value: amount}();

        vm.expectEmit(true, false, false, true, address(escrow));
        emit Withdrawn(beneficiary, amount);

        escrow.withdraw(beneficiary, amount);

        assertEq(escrow.balance(), 0, "Withdraw: Incorrect escrow balance after withdrawal");
        assertEq(address(beneficiary).balance, amount, "Withdraw: Beneficiary did not receive funds");
    }

    /**
     * @dev Test that only the owner can deposit funds.
     */
    function testOnlyOwnerDeposit() public {
        vm.expectRevert();

        vm.startPrank(msg.sender);
        escrow.deposit{value: amount}();
        vm.stopPrank();
        assertEq(escrow.balance(), 0, "OnlyOwnerDeposit: Escrow balance should remain unchanged");
    }

    /**
     * @dev Test that only the owner can withdraw funds.
     */
    function testOnlyOwnerWithdraw() public {
        vm.expectRevert();

        vm.startPrank(msg.sender);
        escrow.withdraw(beneficiary, amount);
        vm.stopPrank();
        assertEq(escrow.balance(), 0, "OnlyOwnerWithdraw: Escrow balance should remain unchanged");
    }
}