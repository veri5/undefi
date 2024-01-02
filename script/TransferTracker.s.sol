// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/evm/TransferTracker.sol";
import "./NetworkDetailsBase.sol";

contract TransferTrackerScript is Script, NetworkDetailsBase {
    TransferTracker public transferTracker;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address initialOwner = address(bytes20(bytes(vm.envString("PUBLIC_ADDRESS"))));

        string memory network = vm.envString("NETWORK");

        (address gateway, ) = getNetworkDetails(network);

        vm.startBroadcast(privateKey);
        transferTracker = new TransferTracker(initialOwner, gateway);
        vm.stopBroadcast();
    }
}