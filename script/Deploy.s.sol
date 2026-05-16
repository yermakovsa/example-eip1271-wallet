// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";

import {ExampleEIP1271Wallet} from "../src/ExampleEIP1271Wallet.sol";

contract Deploy is Script {
    function run() external returns (ExampleEIP1271Wallet wallet) {
        address owner = vm.envAddress("OWNER_ADDRESS");

        vm.startBroadcast();
        wallet = new ExampleEIP1271Wallet(owner);
        vm.stopBroadcast();
    }
}
