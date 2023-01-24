// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract JSONRegistry {
    mapping(address => string) _contractsJSON;

    function setContractJSON(address contractAddress, string memory uri)
        public
    {
        AccessControl subject = AccessControl(contractAddress);
        require(subject.hasRole(subject.DEFAULT_ADMIN_ROLE(), msg.sender));
        _contractsJSON[contractAddress] = uri;
    }

    function contractJSON(address contractAddress)
        external
        view
        returns (string memory)
    {
        return _contractsJSON[contractAddress];
    }
}
