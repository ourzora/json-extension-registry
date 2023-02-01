// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2} from "forge-std/console2.sol";

import {JSONExtensionRegistry} from "../src/JSONExtensionRegistry.sol";

import {ScriptBase} from "./ScriptBase.sol";

contract DeployRegistry is ScriptBase {
    function run() public {
        setUp();
        bytes memory creationCode = type(JSONExtensionRegistry).creationCode;
        console2.logBytes32(keccak256(creationCode));
        bytes32 salt = bytes32(0x72c959bb663305e01921c9b55b2f6c87a3cd5ce9a47589c8e477b44156248d63);

        vm.broadcast(deployer);
        IMMUTABLE_CREATE2_FACTORY.safeCreate2(salt, creationCode);
    }
}