// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "ds-test/test.sol";
import "./MultiSigWallet.sol";

contract MultisigwalletTest is DSTest {
    MultiSigWallet public multisigwallet;
    uint8 signaturesRequired;
    address isAdmin;

    function setUp() public {
        multisigwallet = new MultiSigWallet(
            isAdmin = 0xe42CF2EaCEa0E6fdD8245a4eF7b593a3AE24b741,
            signaturesRequired = 1
        );
    }

    function test_signatures_required() public view returns (bool) {
        if (signaturesRequired == 1) {
            return true;
        }
        return false;
    }

    //symbolic test prove_
    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
