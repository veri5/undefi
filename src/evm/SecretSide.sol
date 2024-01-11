pragma solidity ^0.8.20;

import {Escrow} from "./Escrow.sol";

contract SecretSide {
    mapping(address => uint256) public balances;

    function transfer(address sender, address recipient, uint256 amount) external {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");
        require(balances[sender] >= amount, "Insufficient balance");
        
        // ToDo: Verify Sender's signature

        balances[sender] -= amount;

        bytes memory payload = abi.encodePacked(recipient, amount);
        gateway.callContract(_, payload); // call _execute() on the PublicSide
    }

    function _execute(
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata payload
    ) internal view {
        (address sender, uint256 amount) = abi.decode(payload, (address, uint256));

        require(sender != address(0), "Invalid sender address");
        require(amount > 0, "Withdrawal amount must be greater than zero");

        balances[sender] += amount;
    }
}
