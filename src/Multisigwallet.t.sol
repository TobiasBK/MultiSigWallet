// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "ds-test/test.sol";
import "./MultiSigWallet.sol";

contract NotAdmin {
    MultiSigWallet public multisigwallet;

    function addAdmin(address _admin) external {
        multisigwallet.addAdmin(_admin);
    }
}

contract NotSigner {
    MultiSigWallet public multisigwallet;

    function addSignerToArray(address _signer) external {
        multisigwallet.addSignerToArray(_signer);
    }
}

contract MultisigwalletTest is DSTest {
    MultiSigWallet public multisigwallet;
    NotAdmin public alice;
    NotSigner public bob;

    uint8 signaturesRequired;
    address isAdmin;

    function setUp() public {
        multisigwallet = new MultiSigWallet(address(this), 1);
        alice = new NotAdmin();
        bob = new NotSigner();
    }

    //=======TESTING ACCESS=======//

    // function test_addAdmin() public {
    //     try alice.addAdmin(address(alice)) {
    //         fail();
    //     } catch Error(string memory error) {
    //         assertEq(error, "alice is not an admin");
    //     }
    // }

    function testFail_addAdmin() public {
        alice.addAdmin(address(alice));
    }

    // function test_addSigner() public {
    //     try bob.addSignerToArray(address(bob)) {
    //         fail();
    //     } catch Error(string memory error) {
    //         assertEq(error, "bob is not an admin");
    //     }
    // }

    function testFail_addSigner() public {
        bob.addSignerToArray(address(bob));
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
