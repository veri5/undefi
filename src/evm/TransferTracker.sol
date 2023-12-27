// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TransferTracker {
    mapping(address => uint256) private prevTransferIds;
    mapping(uint256 => TransferRecord) private transferRecords;

    event TransferRequested(uint256 transferId, uint256 amount, address sender); 
    event TransferReceived(uint256 transferId, uint256 amount, address sender); 

    enum TransferStatus {
        Pending,
        Completed,
        Failed
    }

    struct TransferRecord {
        uint256 amount;
        TransferStatus status;
        address sender; 
    }

    function requestTransfer(uint256 amount) external {
        uint256 transferId = _createTransferId(amount);
        transferRecords[transferId] = TransferRecord(amount, TransferStatus.Pending, msg.sender);
        emit TransferRequested(transferId, amount, msg.sender); 
    }

    // ToDo: Manually executed for Miletone I
    function triggerTransfer(uint256 transferId) external {
        TransferRecord storage record = transferRecords[transferId];
        require(record.status == TransferStatus.Pending, "Invalid transfer status");

        record.status = TransferStatus.Completed;
        emit TransferReceived(transferId, record.amount, record.sender); // Emit event to indicate completion
    }

    function receiveTransfer(uint256 transferId, address payable destination) external {
        TransferRecord storage record = transferRecords[transferId];
        require(record.status == TransferStatus.Pending, "Invalid transfer status");
        require(record.amount > 0, "Invalid transfer amount");
        require(record.sender == msg.sender, "Unauthorized sender"); 

        // Ensure destination address is valid
        require(destination != address(0), "Invalid destination address");

        // ToDo: Implement a separated Escrow contract.
        // Transfer funds from the contract
        require(address(this).balance >= record.amount, "Insufficient contract balance");
        destination.transfer(record.amount);

        emit TransferReceived(transferId, record.amount, record.sender);
        record.status = TransferStatus.Completed;
    }

    function _createTransferId(uint256 amount) internal returns (uint256) {
        require(msg.sender != address(0), "Invalid sender");
        uint256 transferId = uint256(keccak256(abi.encodePacked(msg.sender, amount, prevTransferIds[msg.sender])));
        prevTransferIds[msg.sender] = transferId;
        return transferId;
    }
}