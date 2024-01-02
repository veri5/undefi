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
  using StringToAddress for string;
  using AddressToString for address;

  // Mapping to store transfer records
  mapping(uint256 => TransferRecord) public transferRecords;

  // Event emitted when a transfer is executed
  event TransferExecuted(address indexed destination, uint256 amount);

  // Struct to represent a transfer record
  struct TransferRecord {
    address payable destination;
    uint256 amount;
    TransferStatus status;
  }

  // Enumeration for transfer status
  enum TransferStatus {
    Pending,
    Completed,
    Failed
  }

  // Escrow contract used for managing funds
  Escrow public escrow;

  /**
   * @dev Constructor to initialize the TransferTracker contract.
   * @param initialOwner The initial owner address.
   * @param gateway_ The address of the AxelarGateway contract.
   */
  constructor(address initialOwner, address gateway_) AxelarExecutable(gateway_) {
    escrow = new Escrow(initialOwner);
  }

  /**
   * @dev Function to request a transfer.
   * @param destination The address to which the transfer is requested.
   * @param amount The amount to be transferred.
   * @return transferId The unique identifier for the transfer.
   */
  function requestTransfer(address payable destination, uint256 amount) external returns (uint256) {
    uint256 transferId = uint256(keccak256(abi.encodePacked(msg.sender, amount, block.timestamp)));
    transferRecords[transferId] = TransferRecord(destination, amount, TransferStatus.Pending);

    return transferId;
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
    (uint256 transferId) = abi.decode(payload, (uint256));

    TransferRecord storage record = transferRecords[transferId];
    require(record.status == TransferStatus.Pending, "Invalid transfer status");
    require(record.amount > 0, "Invalid transfer amount");
    require(record.destination != address(0), "Invalid transfer destination");

    require(record.amount <= escrow.balance(), "Insufficient contract balance");
    escrow.withdraw(record.destination, record.amount);
    record.status = TransferStatus.Completed;
    
    emit TransferExecuted(record.destination, record.amount);
  }
}
