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
    MultiSigWallet public msw;
    NotAdmin public alice;
    NotSigner public bob;
    address signer;
    address admin;

    function setUp() public {
        msw = new MultiSigWallet(address(this), address(signer), 1);
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

    function test_receive() public {
        uint256 preBalance = address(msw).balance;
        payable(address(msw)).transfer(1 ether);
        uint256 postBalance = address(msw).balance;
        assertEq(preBalance + 1 ether, postBalance);
    }

    function testFail_receive() public {
        uint256 preBalance = address(msw).balance;
        payable(address(msw)).transfer(1 ether);
        uint256 postBalance = address(msw).balance;
        assertEq(preBalance, postBalance);
    }

    function test_addSignaturesrRequired() public {
        msw.addSignaturesRequired(7);
        assertEq(msw.getSignaturesRequired(), 7);
    }

    function testFail_addSignaturesrRequired() public {
        msw.addSignaturesRequired(0);
    }

    //=======PROPERTY-BASED TESTING=======//

    function test_submitTransaction(
        address _to,
        uint128 _valueDue,
        bytes memory _data
    ) public {
        msw = new MultiSigWallet(address(admin), address(this), 1);
        address to = _to;
        uint128 valueDue = _valueDue;
        bytes memory data = _data;
        msw.submitTransaction(to, valueDue, data);
    }

    function testFail_submitTransaction(
        address _to,
        uint128 _valueDue,
        bytes memory _data
    ) public {
        msw = new MultiSigWallet(address(this), address(signer), 1);
        address to = _to;
        uint128 valueDue = _valueDue;
        bytes memory data = _data;
        msw.submitTransaction(to, valueDue, data);
    }

    //  function test_signTransaction() public {
    //     msw = new MultiSigWallet(address(this), address(signer), 1);
    //     msw.signTransaction(_transactionId);
    // }

    // function test_executeTransaction() public {
    //     msw = new MultiSigWallet(address(this), address(signer), 1);
    //     msw.executeTransaction(_transactionId);
    // }

    //=======SYMBOLIC TESTING=======//

    //=======INVARIANT TESTING=======//
}
