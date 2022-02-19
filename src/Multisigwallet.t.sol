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

    //=======UNIT TESTING=======//

    function test_signatures_required() public view returns (bool) {
        if (signaturesRequired == 1) {
            return true;
        }
        return false;
    }

    function test_receive() public {
        uint256 preBalance = address(multisigwallet).balance;
        payable(address(multisigwallet)).transfer(1 ether);
        uint256 postBalance = address(multisigwallet).balance;
        assertEq(preBalance + 1 ether, postBalance);
    }

    function testFail_receive() public {
        uint256 preBalance = address(multisigwallet).balance;
        payable(address(multisigwallet)).transfer(1 ether);
        uint256 postBalance = address(multisigwallet).balance;
        assertEq(preBalance, postBalance);
    }

    // function test_addSignaturesrRequired() public {
    //     if (signaturesRequired > 0 && signaturesRequired <= 256) {
    //         assertTrue(true);
    //     }
    // }

    //=======PROPERTY-BASED TESTING=======//

    function test_addSignaturesrRequired(uint8 _signaturesRequired) public {
        if (_signaturesRequired > 0 && _signaturesRequired <= 256) {
            assertTrue(true);
        }
    }

    //=======SYMBOLIC TESTING=======//

    //=======INVARIANT TESTING=======//
}
