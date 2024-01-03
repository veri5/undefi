// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "../src/evm/Escrow.sol";
import { TransferTracker } from "../src/evm/TransferTracker.sol";

/**
 * @title TestTransferTracker
 * @dev A test contract for the TransferTracker functionality.
 */
contract TestTransferTracker is TransferTracker {
    /**
     * @dev Constructor for initializing the TestTransferTracker contract.
     * @param owner The owner address.
     * @param gateway_ The address of the gateway.
     * @param escrowAddress The address of the escrow.
     */
    constructor(address owner, address gateway_, address escrowAddress) TransferTracker(owner, gateway_, escrowAddress) {}

    /**
     * @dev Executes a transfer externally.
     * @param sourceChain The source chain of the transfer.
     * @param sourceAddress The source address of the transfer.
     * @param payload The payload of the transfer.
     */
    function externalExecute(    
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload) 
    external {
        // Call the internal _execute function
        super._execute(sourceChain, sourceAddress, payload);
    }
}

/**
 * @title TransferTrackerTest
 * @dev A test contract for the TransferTracker functionality.
 */
contract TransferTrackerTest is Test {
    // Addresses for testing purposes
    address owner;
    address gateway_;
    address payable destination;
    address payable unauthorized;

    // Instances of contracts used in testing
    TestTransferTracker transferTracker;
    Escrow escrow;

    // Amount for testing transfers
    uint256 amount;

    /**
    * @dev Sets up initial test conditions.
    */
    function setUp() public {
        // Set up addresses, instances, and testing amount
        owner = address(this);
        gateway_ = makeAddr("gateway_");
        destination = payable(makeAddr("destination"));
        unauthorized = payable(makeAddr("unauthorized"));
        // Deploy a new Escrow contract with the current contract's address as the initial owner
        escrow = new Escrow(owner);
        // Deploy a new TestTransferTracker contract with specified parameters
        transferTracker = new TestTransferTracker(owner, gateway_, address(escrow));
        // Set the testing amount and deposit it into the escrow
        amount = 100 ether;
        escrow.deposit{value: amount}();
    }

    /**
     * @dev Tests the requestTransfer function.
     */
    function testRequestTransfer() public {
        // Calls the requestTransfer function
        uint256 transferId = transferTracker.requestTransfer(destination, amount);

        // Retrieves and asserts details from the transfer record
        (address payable storedDestination, uint256 storedAmount, TransferTracker.TransferStatus storedStatus) = transferTracker.transferRecords(transferId);

        assertEq(storedDestination, destination, "Incorrect destination address in record");
        assertEq(storedAmount, amount, "Incorrect amount in record");
        assertEq(uint256(storedStatus), uint256(TransferTracker.TransferStatus.Pending), "Incorrect status in record");
    }

    /**
     * @dev Tests the executeTransfer function.
     */
    function testExecuteTransfer() public {
        // Calls the requestTransfer function
        uint256 transferId = transferTracker.requestTransfer(destination, amount);

        // Expect an event for the execution of the transfer
        vm.expectEmit(true, false, false, true, address(transferTracker));
        emit TransferTracker.TransferExecuted(destination, amount);

        // Execute the transfer externally, considering it as incoming from the secret network.
        transferTracker.externalExecute("", "", abi.encode(transferId));

        // Retrieves and asserts details from the transfer record
        (address payable storedDestination, uint256 storedAmount, TransferTracker.TransferStatus storedStatus) = transferTracker.transferRecords(transferId);

        assertEq(address(storedDestination).balance, amount, "Destination did not receive funds");
        assertEq(storedAmount, amount, "Incorrect amount in record");
        assertEq(uint256(storedStatus), uint256(TransferTracker.TransferStatus.Completed), "Incorrect status in record");
        assertEq(escrow.balance(), 0, "Incorrect escrow balance after withdrawal");
    }
}
