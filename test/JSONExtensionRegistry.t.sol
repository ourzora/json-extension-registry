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

/// @author @iainnash / @mattlenz
contract JSONRegistryTest is Test {
    JSONExtensionRegistry public registry;
    string ipfsUri = "ipfs://hello";

    function setUp() public {
        registry = new JSONExtensionRegistry();
    }

    function testRegistryI165() public {
        assertTrue(registry.supportsInterface(0x01ffc9a7));
        assertTrue(registry.supportsInterface(0x9ddf4705));
        assertFalse(registry.supportsInterface(0x000000a7));
    }

    function testCorrectOwner() public {
        MockOwnable myOwnable = new MockOwnable();

        registry.setJSONExtension(address(myOwnable), ipfsUri);

        assertEq(registry.getJSONExtension(address(myOwnable)), ipfsUri);
    }

    function testGetName() public {
        assertEq(registry.name(), "JSONMetadataRegistry");
    }

    function testGetRegistryInfo() public {
        assertEq(
            registry.contractInfo(),
            "https://docs.zora.co/json-contract-registry"
        );
    }

    function testIncorrectOwnerOwnable() public {
        MockOwnable myOwnable = new MockOwnable();
        myOwnable.transferOwnership(address(0x1234));

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setJSONExtension(address(myOwnable), ipfsUri);
        assertEq(registry.getJSONExtension(address(myOwnable)), "");

        assertTrue(registry.getIsAdmin(address(myOwnable), address(0x1234)));

        vm.prank(address(0x1234));
        registry.setJSONExtension(address(myOwnable), ipfsUri);
        assertEq(registry.getJSONExtension(address(myOwnable)), ipfsUri);
    }

    function testNotOwnable() public {
        MockContract notOwnable = new MockContract();

        assertFalse(registry.getIsAdmin(address(notOwnable), address(this)));

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setJSONExtension(address(notOwnable), ipfsUri);
    }

    function testUserDirectAccount() public {
        vm.prank(address(0x1234));
        registry.setJSONExtension(
            address(0x1234),
            "http://zora.co/asdf/testing"
        );

        assertEq(
            registry.getJSONExtension(address(0x1234)),
            "http://zora.co/asdf/testing"
        );
    }

    function testIncorrectOwner() public {
        MockOwnable notMyOwnable = new MockOwnable();
        notMyOwnable.renounceOwnership();

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setJSONExtension(address(notMyOwnable), ipfsUri);
    }

    function testAdminRole() public {
        MockAccessControl myAccessControl = new MockAccessControl();
        myAccessControl.grantRole(
            myAccessControl.DEFAULT_ADMIN_ROLE(),
            msg.sender
        );

        registry.setJSONExtension(address(myAccessControl), ipfsUri);
        assertEq(registry.getJSONExtension(address(myAccessControl)), ipfsUri);
    }

    function testNoAdminRole() public {
        MockAccessControl notMyAccessControl = new MockAccessControl();
        notMyAccessControl.revokeRole(
            notMyAccessControl.DEFAULT_ADMIN_ROLE(),
            address(this)
        );

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setJSONExtension(address(notMyAccessControl), ipfsUri);
    }
}
