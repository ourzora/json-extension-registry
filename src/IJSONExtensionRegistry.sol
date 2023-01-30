// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IJSONExtensionRegistry {
    function setAddressJSONExtension(address target, string memory uri)
        external;

    function addressJSONExtension(address target)
        external
        returns (string memory);

    error RequiresContractAdmin();

    event ContractExtensionJSONUpdated(
        address indexed target,
        address indexed updater,
        string newValue
    );
}
