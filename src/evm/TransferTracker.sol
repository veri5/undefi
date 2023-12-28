// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TransferTracker {
    mapping(address => uint256) private prevTransferIds;
    mapping(uint256 => TransferRecord) private transferRecords;

    event FundsDeposited(address indexed escrow, uint256 amount);
    event FundsWithdrawn(address indexed beneficiary, uint256 amount);

    event TransferRequested(address indexed sender, uint256 transferId, uint256 amount); 
    event TransferTriggered(address indexed sender, uint256 transferId, uint256 amount); 
    event TransferReceived(address indexed sender, uint256 transferId, uint256 amount); 

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

    address payable public escrow;

    constructor() {
        escrow = payable(msg.sender); // Set escrow to owner in constructor
    }

    function deposit() external payable {
        require(msg.sender == escrow, "Only escrow can deposit");
        emit FundsDeposited(escrow, msg.value);
        // Handled directly by payable function
    }

    function withdraw(uint256 amount, address payable beneficiary) external {
        require(msg.sender == escrow, "Only escrow can withdraw");
        require(address(this).balance >= amount, "Insufficient contract balance");
        beneficiary.transfer(amount);
        emit FundsWithdrawn(beneficiary, amount);
    }

    function requestTransfer(uint256 amount) external {
        uint256 transferId = _createTransferId(amount);
        transferRecords[transferId] = TransferRecord(amount, TransferStatus.Pending, msg.sender);
        emit TransferRequested(msg.sender, transferId, amount); 
    }

    // ToDo: Manually executed for Miletone I
    function triggerTransfer(uint256 transferId) external {
        TransferRecord storage record = transferRecords[transferId];
        require(record.status == TransferStatus.Pending, "Invalid transfer status");

        record.status = TransferStatus.Completed;
        emit TransferTriggered(record.sender, transferId, record.amount);
    }

    function receiveTransfer(uint256 transferId, address payable beneficiary) external {
        TransferRecord storage record = transferRecords[transferId];
        require(record.status == TransferStatus.Pending, "Invalid transfer status");
        require(record.amount > 0, "Invalid transfer amount");
        require(record.sender == msg.sender, "Unauthorized sender"); 

        // Ensure beneficiary address is valid
        require(beneficiary != address(0), "Invalid beneficiary address");

        // Transfer funds from the contract
        require(address(this).balance >= record.amount, "Insufficient contract balance");
        beneficiary.transfer(record.amount);

        emit TransferReceived(record.sender, transferId, record.amount);
        record.status = TransferStatus.Completed;
    }

    function _createTransferId(uint256 amount) internal returns (uint256) {
        require(msg.sender != address(0), "Invalid sender");
        uint256 transferId = uint256(keccak256(abi.encodePacked(msg.sender, amount, block.timestamp, prevTransferIds[msg.sender])));
        prevTransferIds[msg.sender] = transferId;
        return transferId;
    }
}