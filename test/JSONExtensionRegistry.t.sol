// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import "forge-std/Test.sol";
import "../src/JSONExtensionRegistry.sol";

contract MockOwnable is Ownable {}

contract MockAccessControl is AccessControl {}

contract MockContract is AccessControl {}

contract JSONRegistryTest is Test {
    JSONExtensionRegistry public registry;
    string ipfsUri = "ipfs://hello";

    function setUp() public {
        registry = new JSONExtensionRegistry();
    }

    function testCorrectOwner() public {
        MockOwnable myOwnable = new MockOwnable();

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
        assertEq(registry.contractJSONExtension(address(myAccessControl)), ipfsUri);
    }

    function testNoAdminRole() public {
        MockAccessControl notMyAccessControl = new MockAccessControl();

        vm.expectRevert(IJSONExtensionRegistry.RequiresContractAdmin.selector);
        registry.setContractJSONExtension(address(notMyAccessControl), ipfsUri);
    }
}
