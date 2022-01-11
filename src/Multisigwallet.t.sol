// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Multisigwallet.sol";

contract MultisigwalletTest is DSTest {
    Multisigwallet multisigwallet;

    uint8 signersRequired;
    address[] signers;
    
    struct Transaction {
        address recipient;
        uint256 valueDue;
        bytes data;
        uint8 numSigners;
        bool completed;
    }

    Transaction[] public transactionsArray;

    mapping(address => bool) public isSigner;


    function setUp(address[] memory _signers, uint8 _signersRequired) public {
       //multisigwallet = new Multisigwallet([], 1);
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }

}
