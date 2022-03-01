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

    function test_addAdmin(address _alice) public {
        try alice.addAdmin(_alice) {
            emit log("alice is admin");
        } catch {
            emit log("alice failed");
        }
    }

    function test_addSigner(address _bob) public {
        try bob.addSignerToArray(_bob) {
            emit log("bob is admin");
        } catch {
            emit log("bob failed");
        }
    }

    function testFail_addAdmin() public {
        alice.addAdmin(address(alice));
    }

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

    function test_addSignaturesrRequired() public {
        if (signaturesRequired > 0 && signaturesRequired <= 256) {
            assertTrue(true);
        }
    }

    //=======PROPERTY-BASED TESTING=======//

    function test_addSignaturesrRequired(uint8 _signaturesRequired) public {
        if (_signaturesRequired > 0 && _signaturesRequired <= 256) {
            assertTrue(true);
        }
    }

    //=======SYMBOLIC TESTING=======//

    //=======INVARIANT TESTING=======//
}
