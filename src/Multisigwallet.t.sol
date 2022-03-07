// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "ds-test/test.sol";
import "./MultiSigWallet.sol";

contract NotAdmin {
    MultiSigWallet public multisigwallet;

    function addAdmin(address _admin) external {
        multisigwallet.addAdmin(_admin);
    }

    function executeTransaction() external {
        multisigwallet.executeTransaction(0);
    }
}

contract NotSigner {
    MultiSigWallet public multisigwallet;

    function addSignerToArray(address _signer) external {
        multisigwallet.addSignerToArray(_signer);
    }

    function submitTransaction(
        address _to,
        uint128 _valueDue,
        bytes memory _data
    ) external {
        address to = _to;
        uint128 valueDue = _valueDue;
        bytes memory data = _data;
        multisigwallet.submitTransaction(to, valueDue, data);
    }
}

contract MultisigwalletTest is DSTest {
    MultiSigWallet public msw;
    NotAdmin public alice;
    NotSigner public bob;

    address public signer;
    address public admin;
    address public eve = address(0xe);

    //=======SETUP TESTS=======//

    function setUp() public {
        msw = new MultiSigWallet(address(this), address(signer), 1);
        alice = new NotAdmin();
        bob = new NotSigner();
    }

    receive() external payable {}

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

    function test_adminCanSubmitTransaction() public {
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
        uint8 signaturesRequired = 1;
        msw.addSignaturesRequired(0);
        assertEq(0, signaturesRequired);
    }

    //=======SUBMIT TX TESTS=======//

    function test_signerSubmitTransaction(
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

    function testFail_nonSignerSubmitTransaction(
        address _to,
        uint128 _valueDue,
        bytes memory _data
    ) public {
        address to = _to;
        uint128 valueDue = _valueDue;
        bytes memory data = _data;
        bob.submitTransaction(to, valueDue, data);
    }

    //=======SIGNER TX PROCESS TESTS=======//

    function test_signerProcess() public {
        msw = new MultiSigWallet(address(admin), address(this), 1);
        msw.submitTransaction(eve, 1, "0x0");
        msw.signTransaction(0);
    }

    //=======ADMIN TX PROCESS TESTS=======//

    function test_adminProcess() public {
        payable(address(msw)).transfer(1 ether);
        //mockTransaction(not needed now):
        //Transaction[] memory transactionsArray = new Transaction[](1);
        // transactionsArray[0] = Transaction({
        //     recipient: address(0xe),
        //     valueDue: 1 ether,
        //     data: "",
        //     signaturesCollected: 1,
        //     completed: false
        // });
        msw.submitTransaction(eve, 1, "0x0");
        msw.signTransaction(0);
        msw.executeTransaction(0);
    }
}
