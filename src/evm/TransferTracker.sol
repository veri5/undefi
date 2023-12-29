// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Escrow} from "./Escrow.sol";

/**
 * @title TransferTracker
 * @dev A contract for tracking and managing fund transfers with an associated escrow.
 */
contract TransferTracker is Ownable {
  mapping(uint256 => TransferRecord) public transferRecords;

  event TransferRequested(address indexed origin, uint256 amount);
  event TransferTriggered(address indexed destination, uint256 amount);

  struct TransferRecord {
    address payable origin;
    uint256 amount;
    TransferStatus status;
  }

  enum TransferStatus {
    Pending,
    Completed,
    Failed
  }

  Escrow public escrow;

  /**
   * @dev Constructor to initialize the TransferTracker contract.
   * @param owner The address that will be set as the owner of the contract.
   */
  constructor(address owner) Ownable(owner) { 
    escrow = new Escrow();
  }

  /**
   * @dev Requests a fund transfer, creating a transfer record.
   * @param origin The address from which the transfer is requested.
   * @param amount The amount of funds to be transferred.
   * @return transferId The unique identifier for the transfer.
   */
  function requestTransfer(address payable origin, uint256 amount) external returns (uint256) {
    uint256 transferId = _createTransferId(amount);
    transferRecords[transferId] = TransferRecord(origin, amount, TransferStatus.Pending);

    emit TransferRequested(origin, amount);
    return transferId;
  }

  /**
   * @dev Triggers a fund transfer to a specified destination.
   * @param destination The address to which the transfer is triggered.
   * @param transferId The unique identifier for the transfer.
   */
  function triggerTransfer(address payable destination, uint256 transferId) external onlyOwner {
    TransferRecord storage record = transferRecords[transferId];
    require(record.status == TransferStatus.Pending, "Invalid transfer status");
    require(record.amount > 0, "Invalid transfer amount");

    require(record.amount <= escrow.balance(), "Insufficient contract balance");
    escrow.withdraw(destination, record.amount);

    emit TransferTriggered(destination, record.amount);
    record.status = TransferStatus.Completed;
  }

  /**
   * @dev Internal function to create a unique transfer ID based on the sender's address, amount, and timestamp.
   * @param amount The amount of funds to be transferred.
   * @return transferId The unique identifier for the transfer.
   */
  function _createTransferId(uint256 amount) internal view returns (uint256) {
    require(msg.sender != address(0), "Invalid sender");
    uint256 transferId = uint256(keccak256(abi.encodePacked(msg.sender, amount, block.timestamp)));
    return transferId;
  }
}