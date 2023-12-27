// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/evm/SendReceive.sol";
import "./NetworkDetailsBase.sol";

contract SendReceiveScript is Script, NetworkDetailsBase {
    SendReceive public sendReceive;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        string memory network = vm.envString("NETWORK");

        (address gateway, address gasService) = getNetworkDetails(network);

        vm.startBroadcast(privateKey);
        sendReceive = new SendReceive(gateway, gasService, network);
        vm.stopBroadcast();
    }
}