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
        assertTrue(registry.supportsInterface(0xf6cf4cbc));
        assertFalse(registry.supportsInterface(0x000000a7));
    }

    function testCorrectOwner() public {
        MockOwnable myOwnable = new MockOwnable();

        registry.setAddressJSONExtension(address(myOwnable), ipfsUri);

        assertEq(registry.addressJSONExtension(address(myOwnable)), ipfsUri);
    }

    function testIncorrectOwnerOwnable() public {
        MockOwnable myOwnable = new MockOwnable();
        myOwnable.transferOwnership(address(0x1234));

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setAddressJSONExtension(address(myOwnable), ipfsUri);
        assertEq(registry.addressJSONExtension(address(myOwnable)), "");

        vm.prank(address(0x1234));
        registry.setAddressJSONExtension(address(myOwnable), ipfsUri);
        assertEq(registry.addressJSONExtension(address(myOwnable)), ipfsUri);
    }

    function testNotOwnable() public {
        MockContract notOwnable = new MockContract();

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setAddressJSONExtension(address(notOwnable), ipfsUri);
    }

    function testUserDirectAccount() public {
        vm.prank(address(0x1234));
        registry.setAddressJSONExtension(address(0x1234), "http://zora.co/asdf/testing");

        assertEq(registry.addressJSONExtension(address(0x1234)), "http://zora.co/asdf/testing");
    }

    function testIncorrectOwner() public {
        MockOwnable notMyOwnable = new MockOwnable();
        notMyOwnable.renounceOwnership();

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setAddressJSONExtension(address(notMyOwnable), ipfsUri);
    }

    function testAdminRole() public {
        MockAccessControl myAccessControl = new MockAccessControl();
        myAccessControl.grantRole(
            myAccessControl.DEFAULT_ADMIN_ROLE(),
            msg.sender
        );

        registry.setAddressJSONExtension(address(myAccessControl), ipfsUri);
        assertEq(
            registry.addressJSONExtension(address(myAccessControl)),
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
        registry.setAddressJSONExtension(address(notMyAccessControl), ipfsUri);
    }
}
