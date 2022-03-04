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
    address eve;

    uint8 private signaturesRequired = 1;

    struct Transaction {
        address recipient;
        uint256 valueDue;
        bytes data;
        uint8 signaturesCollected;
        bool completed;
    }

    Transaction[] public transactionsArray;

    function setUp() public {
        msw = new MultiSigWallet(address(this), address(signer), 1);
        alice = new NotAdmin();
        bob = new NotSigner();
    }

    //=======ACCESS TESTS=======//

    function test_addAdmin() public {
        try alice.addAdmin(address(0x0)) {
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
        assertEq(address(alice), address(admin));
    }

    function testFail_addSigner() public {
        bob.addSignerToArray(address(bob));
        assertEq(address(bob), address(signer));
    }

    function test_adminCannotSubmitTx() public {
        try msw.submitTransaction(eve, 1, "0x0") {
            emit log("Submitted tx");
        } catch {
            emit log("Admin can't submit tx");
        }
    }

    function test_signerCannotExecute() public {
        msw = new MultiSigWallet(address(admin), address(this), 1);
        msw.submitTransaction(eve, 1, "0x0");
        msw.signTransaction(0);
        try msw.executeTransaction(0) {
            emit log("Executed tx");
        } catch {
            emit log("Only admin can execute tx");
        }
    }

    //=======RECEIVE/WITHDRAW ETH TESTS=======//

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

    //=======ADD TO THE NO. OF REQUIRED SIGNATURES=======//

    function test_addSignaturesrRequired() public {
        msw.addSignaturesRequired(7);
        assertEq(msw.getSignaturesRequired(), 7);
    }

    function testFail_addSignaturesrRequired() public {
        msw.addSignaturesRequired(0);
        assertEq(0, signaturesRequired);
    }

    //=======SUBMIT TX TESTS=======//

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
        //msw = new MultiSigWallet(address(this), address(signer), 1);
        address to = _to;
        uint128 valueDue = _valueDue;
        bytes memory data = _data;
        msw.submitTransaction(to, valueDue, data);
    }

    //=======SIGNER SUBMIT AND SIGN TX TESTS=======//

    function test_signerProcess() public {
        msw = new MultiSigWallet(address(admin), address(this), 1);
        msw.submitTransaction(eve, 1, "0x0");
        msw.signTransaction(0);
    }
}
