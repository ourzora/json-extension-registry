// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/JSONRegistry.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MockOwnable is Ownable {}

contract MockAccessControl is AccessControl {}

contract MockContract is AccessControl {}

contract JSONRegistryTest is Test {
    JSONRegistry public registry;
    string ipfsUri = "ipfs://hello";

    function setUp() public {
        registry = new JSONRegistry();
    }

    function testCorrectOwner() public {
        MockOwnable myOwnable = new MockOwnable();

        registry.setContractJSON(address(myOwnable), ipfsUri);

        assertEq(registry.contractJSON(address(myOwnable)), ipfsUri);
    }

    function testNotOwnable() public {
        MockContract notOwnable = new MockContract();

        vm.expectRevert();
        registry.setContractJSON(address(notOwnable), ipfsUri);
    }

    function testIncorrectOwner() public {
        MockOwnable notMyOwnable = new MockOwnable();
        notMyOwnable.renounceOwnership();

        vm.expectRevert(abi.encodePacked());
        registry.setContractJSON(address(notMyOwnable), ipfsUri);
    }

    function testAdminRole() public {
        MockAccessControl myAccessControl = new MockAccessControl();
        myAccessControl.grantRole(
            myAccessControl.DEFAULT_ADMIN_ROLE(),
            msg.sender
        );

        registry.setContractJSON(address(myAccessControl), ipfsUri);
        assertEq(registry.contractJSON(address(myAccessControl)), ipfsUri);
    }

    function testNoAdminRole() public {
        MockAccessControl notMyAccessControl = new MockAccessControl();

        vm.expectRevert("Admin role required");
        registry.setContractJSON(address(notMyAccessControl), ipfsUri);
    }
}
