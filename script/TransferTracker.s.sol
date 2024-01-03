// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Updated pragma for compatibility

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/evm/TransferTracker.sol";
import "../src/evm/Escrow.sol";
import "./NetworkDetailsBase.sol";

contract TransferTrackerScript is Script, NetworkDetailsBase {
    TransferTracker public transferTracker;
    Escrow public escrow;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address initialOwner = address(bytes20(bytes(vm.envString("PUBLIC_ADDRESS"))));
        string memory network = vm.envString("NETWORK");
        (address gateway, ) = getNetworkDetails(network);

        vm.startBroadcast(privateKey);
        
        escrow = new Escrow(initialOwner);
        transferTracker = new TransferTracker(gateway, address(escrow));

        vm.stopBroadcast();

        console.log("TransferTracker deployed at:", address(transferTracker));
        console.log("Escrow deployed at:", address(escrow)); // Added deployment log
    }
}