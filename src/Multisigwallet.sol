// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

contract Multisigwallet {

    uint8 signaturesRequired;
    address[] signers;
    
    struct Transaction {
        address recipient;
        uint256 valueDue;
        bytes data;
        uint8 numSigners;
        bool completed;
    }
    //an arr of structs
    Transaction[] public transactionsArray;

    mapping(address => bool) public isSigner;

    event ConstructorSetup(address indexed sender, address[] signers, uint8 signersRequired);
    event Deposit(address indexed sender, uint256 value);
    event Submission(address indexed sender, uint256 id, address receipient, uint256 value, bytes data);
    event Executed(address indexed sender, uint256 id);

    modifier onlySigners() {
        require(isSigner[msg.sender], "Not an owner");
        _;
    }

    constructor(address[] memory _signers, uint8 _signaturesRequired) {

        require(_signers.length > 0 && _signers.length < 64, "Setup: No. signers incorect");
        require(_signaturesRequired > 0 && _signaturesRequired <= _signers.length, "Setup: No. of signers required is incorrect");

        for(uint8 i; i < _signers.length; i++){

            address approvedSigner = _signers[i];

            if(approvedSigner == address(0)) {
                revert("Setup: Don't use address(0)");
            } else if(isSigner[approvedSigner]) {
                revert("Setup: Already a signer");
            } else {
                isSigner[approvedSigner] = true;
                signers.push(approvedSigner);
            }
        }

        emit ConstructorSetup(msg.sender, _signers, _signaturesRequired);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(
        address _to, 
        uint256 _valueDue,
        bytes memory _data
        ) public onlySigners {

        uint256 transactionId = transactionsArray.length;

        transactionsArray.push(Transaction ({
            recipient: _to,
            valueDue: _valueDue,
            data: _data,
            numSigners: 0,
            completed: false
        }));

        emit Submission(msg.sender, transactionId, _to, _valueDue, _data);
    }

    function executeTx(uint256 _transactionId) public onlySigners {

        Transaction storage transaction = transactionsArray[_transactionId];

        require(transaction.numSigners >= signaturesRequired, "Not enough signatures for approval");

        transaction.completed = true;   

        (bool success,) = transaction.recipient.call{value: transaction.valueDue }("");
        require(success, "Failed");

        emit Executed(msg.sender, _transactionId); 
    }

    function getSignersArray() public view returns(address[] memory) {
        return signers;
    }

    function getTransaction(uint256 _transactionId) public onlySigners view returns(
        address _recipient,
        uint256 _valueDue,
        bytes memory _data, 
        uint256 _numSigners,
        bool _completed
        ) 
    {
        Transaction storage transaction = transactionsArray[_transactionId];
        
        return(
            transaction.recipient,
            transaction.valueDue,
            transaction.data,
            transaction.numSigners,
            transaction.completed 
        );
    }

    function addSigner(address _newSigner) public onlySigners {

        if(isSigner[_newSigner] || _newSigner != address(0)) {
            revert("Cannot add signer");
        }

        signers.push(_newSigner);

        isSigner[_newSigner] = true;
    }

    function removeSigner(address _badSigner) public onlySigners {
    
        if(!isSigner[_badSigner]) {
            revert("Not a signer");
        }

        //cast address to uint so delete can be used
        uint256 badSignerId = uint256(uint160(_badSigner));

        //does not change arr length, resets arr value to default value
        delete signers[badSignerId];
    }

}
