// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "../src/evm/Escrow.sol";
import { TransferTracker } from "../src/evm/TransferTracker.sol";

/**
 * @title TransferTrackerTest Contract
 * @dev Contract designed for testing the TransferTracker contract functionality.
 */
contract TransferTrackerTest is Test {
    // Addresses for testing purposes
    address owner;
    address payable origin;
    address payable destination;
    address payable unauthorized;

    // Instances of contracts used in testing
    TransferTracker transferTracker;
    Escrow escrow;

    // Amount for testing transfers
    uint256 amount;

    /**
     * @dev Sets up initial test conditions.
     */
    function setUp() public {
        owner = payable(address(this));
        origin = payable(makeAddr("origin"));
        destination = payable(makeAddr("destination"));
        unauthorized = payable(makeAddr("unauthorized"));
        transferTracker = new TransferTracker(owner);
        amount = 100 ether;
        escrow = transferTracker.escrow();
        escrow.deposit{value: amount}();
    }

    /**
     * @dev Tests the requestTransfer function.
     */
    function testRequestTransfer() public {
        // Emits an event for expected transfer request
        vm.expectEmit(true, false, false, true, address(transferTracker));
        emit TransferTracker.TransferRequested(origin, amount);

        // Calls the requestTransfer function
        uint256 transferId = transferTracker.requestTransfer(origin, amount);

        // Retrieves and asserts details from the transfer record
        (address payable storedOrigin, uint256 storedAmount, TransferTracker.TransferStatus storedStatus) = transferTracker.transferRecords(transferId);

        assertEq(storedOrigin, origin, "Incorrect origin in record");
        assertEq(storedAmount, amount, "Incorrect amount in record");
        assertEq(uint256(storedStatus), uint256(TransferTracker.TransferStatus.Pending), "Incorrect status in record");
    }

    /**
     * @dev Tests the triggerTransfer function.
     */
    function testTriggerTransfer() public {
        // Emits an event for expected transfer request
        vm.expectEmit(true, false, false, true, address(transferTracker));
        emit TransferTracker.TransferRequested(origin, amount);

        // Calls the requestTransfer function
        uint256 transferId = transferTracker.requestTransfer(origin, amount);

        // Calls the triggerTransfer function
        transferTracker.triggerTransfer(destination, transferId);

        // Retrieves and asserts details from the transfer record after triggering
        (,, TransferTracker.TransferStatus storedStatus) = transferTracker.transferRecords(transferId);

        assertEq(uint256(storedStatus), uint256(TransferTracker.TransferStatus.Completed), "Incorrect status in record");
        assertEq(address(destination).balance, amount, "Destination did not receive funds");
        assertEq(escrow.balance(), 0, "Incorrect escrow balance after withdrawal");
    }

    /**
     * @dev Tests that only the owner can trigger a transfer.
     */
    function testOnlyOwnerTriggerTransfer() public {
        // Calls the requestTransfer function
        uint256 transferId = transferTracker.requestTransfer(origin, amount);

        // Expects a revert if an unauthorized address attempts to trigger the transfer
        vm.expectRevert();

        // Pranks the system with an unauthorized address and attempts to trigger the transfer
        vm.prank(unauthorized);
        transferTracker.triggerTransfer(destination, transferId);
    }
}