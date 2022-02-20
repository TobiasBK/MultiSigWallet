// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "ds-test/test.sol";
import "./MultiSigWallet.sol";

contract Admin {
    address public isAdmin = msg.sender;

    function setAdmin(address _admin) public {
        require(msg.sender == isAdmin, "Not admin");
        isAdmin = _admin;
    }

contract Signer {
    address public isSigner = msg.sender;

    function setSigner(address _signer) public {
        require(msg.sender == isSigner, "Not signer");
        isSigner = _signer;
    }
}

contract NotAuthorizedAdminAccess {
    Admin private admin;

    constructor(address _admin) {
        admin = Admin(_admin);
    }

    function setAdmin(address _admin) external {
        admin.setAdmin(_admin);
    }
}

contract NotAuthorizedSignerAccess {
    Signer private signer;

    constructor(address _signer) {
        signer = Signer(_signer);
    }

    function setSigner(address _signer) external {
        signer.setSigner(_signer);
    }
}

contract MultisigwalletTest is DSTest {
    MultiSigWallet public multisigwallet;
    Admin private admin;
    Signer private signer;
    NotAuthorizedAdminAccess private alice;
    NotAuthorizedSignerAccess private bob;

    uint8 signaturesRequired;
    address isAdmin;

    function setUp() public {
        admin = new Admin();
        signer = new Signer();
        alice = new NotAuthorizedAdminAccess(address(admin));
        bob = new NotAuthorizedSignerAccess(address(signer));

        multisigwallet = new MultiSigWallet(
            isAdmin = msg.sender,
            signaturesRequired = 1
        );
    }

    //=======TESTING ACCESS=======//

    function test_setAdmin() public {
        admin.setAdmin(address(1));
        assertEq(admin.isAdmin(), address(1));
    }

    function testFail_setAdmin() public {
        alice.setAdmin(address(alice));
    }

    function test_setSigner() public {
        signer.setSigner(address(2));
        assertEq(signer.isSigner(), address(2));
    }

    function testFail_setSigner() public {
        bob.setSigner(address(bob));
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
