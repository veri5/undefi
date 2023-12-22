// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, Vm} from "forge-std/Test.sol";
import {PiggyBank, PiggyBankEvents} from "../src/misc/PiggyBank.sol";

contract PiggyBankTest is Test, PiggyBankEvents {
    address internal constant RECEIVER =
        address(uint160(uint256(keccak256("piggy bank test receiver"))));

    function setUp() public {
        vm.label(msg.sender, "MSG_SENDER");
        vm.label(RECEIVER, "RECEIVER");
    }

    function testPiggyBank_Withdraw() public {
        // Create PiggyBank contract
        PiggyBank piggyBank = new PiggyBank();
        uint256 _amount = 1000;

        // Deposit
        vm.deal(msg.sender, _amount);
        vm.startPrank(msg.sender);
        (bool _success, ) = address(piggyBank).call{value: _amount}(
            abi.encodeWithSignature("deposit(address)", msg.sender)
        );
        assertTrue(_success, "deposited payment.");
        vm.stopPrank();

        // Set withdraw event expectations
        vm.expectEmit(true, false, false, true, address(piggyBank));
        emit Withdrawn(msg.sender, 1000);

        // Withdraw
        vm.startPrank(msg.sender);
        piggyBank.withdraw(_amount);
        vm.stopPrank();
    }

    function testPiggyBank_Deposit() public {
        PiggyBank piggyBank = new PiggyBank();
        uint256 _amount = 1000;

        // Start recording all emitted events
        vm.recordLogs();

        // Deposit
        vm.deal(msg.sender, _amount);
        vm.startPrank(msg.sender);
        (bool _success, ) = address(piggyBank).call{value: _amount}(
            abi.encodeWithSignature("deposit(address)", RECEIVER)
        );
        vm.stopPrank();

        assertTrue(_success, "deposited payment failure.");

        // Consume the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // Check logs
        bytes32 deposited_event_signature = keccak256(
            "Deposited(address,address,uint256)"
        );

        for (uint256 i; i < entries.length; i++) {
            if (entries[i].topics[0] == deposited_event_signature) {
                assertEq(
                    address(uint160(uint256((entries[i].topics[1])))),
                    msg.sender,
                    "emitted sender mismatch."
                );
                assertEq(
                    address(uint160(uint256((entries[i].topics[2])))),
                    RECEIVER,
                    "emitted receiver mismatch."
                );
                assertEq(
                    abi.decode(entries[i].data, (uint256)),
                    _amount,
                    "emitted amount mismatch."
                );
                assertEq(
                    entries[i].emitter,
                    address(piggyBank),
                    "emitter contract mismatch."
                );

                break;
            }

            if (i == entries.length - 1)
                fail("emitted deposited event not found.");
        }
    }
}