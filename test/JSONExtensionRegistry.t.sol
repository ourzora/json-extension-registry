// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import "forge-std/Test.sol";
import "../src/JSONExtensionRegistry.sol";

contract MockOwnable is Ownable {}

contract MockAccessControl is AccessControl {
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}

contract MockContract is AccessControl {}

contract JSONRegistryTest is Test {
    JSONExtensionRegistry public registry;
    string ipfsUri = "ipfs://hello";
    
    function setUp() public {
        registry = new JSONExtensionRegistry();
    }

    function testRegistryI165() public {
        assertTrue(registry.supportsInterface(0x01ffc9a7));
        assertTrue(registry.supportsInterface(0x11556274));
        assertFalse(registry.supportsInterface(0x000000a7));
    }

    function testCorrectOwner() public {
        MockOwnable myOwnable = new MockOwnable();

        registry.setContractJSONExtension(address(myOwnable), ipfsUri);

        assertEq(registry.contractJSONExtension(address(myOwnable)), ipfsUri);
    }

    function testIncorrectOwnerOwnable() public {
        MockOwnable myOwnable = new MockOwnable();
        myOwnable.transferOwnership(address(0x1234));

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setContractJSONExtension(address(myOwnable), ipfsUri);
        assertEq(registry.contractJSONExtension(address(myOwnable)), "");

        vm.prank(address(0x1234));
        registry.setContractJSONExtension(address(myOwnable), ipfsUri);
        assertEq(registry.contractJSONExtension(address(myOwnable)), ipfsUri);
    }

    function testNotOwnable() public {
        MockContract notOwnable = new MockContract();

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setContractJSONExtension(address(notOwnable), ipfsUri);
    }

    function testIncorrectOwner() public {
        MockOwnable notMyOwnable = new MockOwnable();
        notMyOwnable.renounceOwnership();

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setContractJSONExtension(address(notMyOwnable), ipfsUri);
    }

    function testAdminRole() public {
        MockAccessControl myAccessControl = new MockAccessControl();
        myAccessControl.grantRole(
            myAccessControl.DEFAULT_ADMIN_ROLE(),
            msg.sender
        );

        registry.setContractJSONExtension(address(myAccessControl), ipfsUri);
        assertEq(
            registry.contractJSONExtension(address(myAccessControl)),
            ipfsUri
        );
    }

    function testNoAdminRole() public {
        MockAccessControl notMyAccessControl = new MockAccessControl();
        notMyAccessControl.revokeRole(
            notMyAccessControl.DEFAULT_ADMIN_ROLE(),
            address(this)
        );

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setContractJSONExtension(address(notMyAccessControl), ipfsUri);
    }
}
