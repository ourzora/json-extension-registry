// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import {IOwnable} from "./IOwnable.sol";
import {IJSONExtensionRegistry} from "./IJSONExtensionRegistry.sol";

/// @notice JSONExtensionRegistry
contract JSONExtensionRegistry is IJSONExtensionRegistry, ERC165 {
    mapping(address => string) contractsJSONURIs;

    function isContractAdmin(address contractAddress, address expectedAdmin)
        internal
        view
        returns (bool)
    {
        // If we're calling from the contract or EOA
        if (contractAddress == expectedAdmin) {
            return true;
        }
        if (contractAddress.code.length > 0) {
            // Check if the contract supports ownable()
            try IOwnable(contractAddress).owner() returns (address owner) {
                if (owner == expectedAdmin) {
                    return true;
                }
            } catch {}
            // Check if the contract supports accessControl and allow admins
            try
                IAccessControl(contractAddress).hasRole(
                    bytes32(0x00),
                    expectedAdmin
                )
            returns (bool hasRole) {
                if (hasRole) {
                    return true;
                }
            } catch {}
        }
        return false;
    }

    modifier onlyContractAdmin(address contractAddress) {
        if (!isContractAdmin(contractAddress, msg.sender)) {
            revert RequiresContractAdmin();
        }
        _;
    }

    /// @notice Contract Name Getter
    /// @dev Used to identify contract
    /// @return string contract name
    function name() external pure returns (string memory) {
        return "JSONMetadataRegistry";
    }

    /// @notice Contract Information URI Getter
    /// @dev Used to provide contract information
    /// @return string contract information uri
    function contractInfo() external pure returns (string memory) {
        // return contract information uri
        return "https://docs.zora.co/json-contract-registry";
    }

    ///
    function setContractJSONExtension(
        address contractAddress,
        string memory uri
    ) external onlyContractAdmin(contractAddress) {
        contractsJSONURIs[contractAddress] = uri;
    }

    function contractJSONExtension(address contractAddress)
        external
        view
        returns (string memory)
    {
        return contractsJSONURIs[contractAddress];
    }

    error By(bytes4);

    function supportsInterface(bytes4 interfaceId) override public view returns (bool) {
        return
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IJSONExtensionRegistry).interfaceId;
    }
}
