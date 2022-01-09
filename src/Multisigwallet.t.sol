// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Multisigwallet.sol";

contract MultisigwalletTest is DSTest {
    Multisigwallet multisigwallet;

    function setUp() public {
        multisigwallet = new Multisigwallet();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
