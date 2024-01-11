pragma solidity ^0.8.20;

import {Escrow} from "./Escrow.sol";

contract PublicSide {
    Escrow public escrow;

    constructor(address escrowAddress) {
        escrow = Escrow(escrowAddress);
    }

    function deposit(address sender, uint256 amount) external payable {
        require(sender != address(0), "Invalid sender address");
        require(amount > 0, "Deposit amount must be greater than zero");
        
        escrow.deposit(amount);

        bytes memory payload = abi.encodePacked(sender, amount);
        gateway.callContract(_, payload); // call _execute() on the SecretSide
    }

    function _execute(
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata payload
    ) internal view {
        (address recipient, uint256 amount) = abi.decode(payload, (address, uint256));

        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Withdrawal amount must be greater than zero");

        escrow.withdraw(recipient, amount);
    }
}