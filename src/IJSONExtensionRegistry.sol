// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IJSONExtensionRegistry {
    function setContractJSONExtension(address contractAddress, string memory uri)
        external;

    function contractJSONExtension(address contractAddress)
        external
        returns (string memory);

    error RequiresContractAdmin();

    event ContractExtensionJSONUpdated(
        address indexed contractAddress,
        address indexed updater,
        string newValue
    );
}
