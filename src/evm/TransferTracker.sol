// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AxelarExecutable} from "@axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {StringToAddress, AddressToString} from "@axelar-gmp-sdk-solidity/contracts/libs/AddressString.sol";

import {Escrow} from "./Escrow.sol";

/**
 * @title TransferTracker
 * @dev Contract to track and execute transfers using AxelarGateway.
 */
contract TransferTracker is AxelarExecutable {
    // Using statements for string-to-address and address-to-string conversion
    using StringToAddress for string;
    using AddressToString for address;

    // Mapping to store transfer records
    mapping(uint256 => TransferRecord) public transferRecords;

    // Event emitted when a transfer is created
    event TransferCreated(uint256 indexed transferId, TransferStatus status, uint256 timestamp);
    // Event emitted when a transfer is executed
    event TransferExecuted(uint256 indexed transferId, TransferStatus status, uint256 timestamp);

    // Struct to represent a transfer record
    struct TransferRecord {
        address payable destination;
        uint256 amount;
        TransferStatus status;
        uint256 timestamp;
    }

    // Enumeration for transfer status
    enum TransferStatus {
        Pending,
        Completed,
        Failed
    }

    // External Escrow contract used for managing funds
    Escrow public escrow;

    /**
     * @dev Constructor to initialize the TransferTracker contract.
     * @param gateway_ The address of the AxelarGateway contract.
     * @param escrowAddress The address of the external Escrow contract.
     */
    constructor(address gateway_, address escrowAddress) AxelarExecutable(gateway_) {
        // Set the external Escrow contract address
        escrow = Escrow(escrowAddress);
    }

    /**
     * @dev Creates a transfer record.
     * @param destination The address to which the transfer is being made.
     * @param amount The amount to be transferred.
     * @return transferId The unique identifier for the transfer record.
     */
    function createTransferRecord(address payable destination, uint256 amount) 
        external
        returns (uint256 transferId) 
    {
        // Ensure destination address and amount are valid
        require(destination != address(0), "Destination address cannot be null");
        require(amount > 0, "Amount cannot be zero");

        // Generate a unique transferId using keccak256
        transferId = uint256(keccak256(abi.encodePacked(msg.sender, amount, block.timestamp)));
        
        // Create a new TransferRecord
        TransferRecord memory record = TransferRecord(destination, amount, TransferStatus.Pending, block.timestamp);

        // Store the transfer record in the mapping
        transferRecords[transferId] = record;

        // Emit an event indicating the creation of a new transfer record
        emit TransferCreated(transferId, record.status, record.timestamp);
    }

    /**
     * @dev Reads a transfer record.
     * @param transferId The unique identifier for the transfer record.
     * @return destination The address to which the transfer was made.
     * @return amount The amount that was transferred.
     * @return status The status of the transfer (Pending, Completed, Failed).
     * @return timestamp The timestamp when the transfer record was created.
     */
    function readTransferRecord(uint256 transferId)
        external
        view
        returns (
            address payable destination,
            uint256 amount,
            TransferStatus status,
            uint256 timestamp
        )
    {
        // Retrieve the transfer record from the mapping
        TransferRecord memory record = transferRecords[transferId];

        // Return the components of the transfer record
        return (record.destination, record.amount, record.status, record.timestamp);
    }

    /**
     * @dev Internal function to execute a transfer.
     * @param payload The payload containing the transferId.
     */
    function _execute(
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata payload
    ) internal override {      
        // Decode the payload to get the transferId
        (uint256 transferId) = abi.decode(payload, (uint256));

        // Retrieve the transfer record
        TransferRecord storage record = transferRecords[transferId];
        
        // Check if the transfer status is Pending and the amount and destination are valid
        require(record.status == TransferStatus.Pending, "Invalid transfer status");
        require(record.amount > 0, "Invalid transfer amount");
        require(record.destination != address(0), "Invalid transfer destination");

        // Check if the contract has sufficient balance for the transfer
        require(record.amount <= escrow.balance(), "Insufficient contract balance");

        // Withdraw funds from the external escrow and update the transfer status to Completed
        escrow.withdraw(record.destination, record.amount);
        record.status = TransferStatus.Completed;
        
        // Emit event for the executed transfer
        emit TransferExecuted(transferId, record.status, record.timestamp);
    }
}