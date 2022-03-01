// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

/**
 * @notice This is a multi-signature wallet that separates Signers from Admins.
 * @dev Admins can add other Admins and Signers and Execute Transactions. Signers can only Submit and Sign Transactions.
 */
contract MultiSigWallet {
    uint8 public signaturesRequired;

    address[] signers;

    struct Transaction {
        address recipient;
        uint256 valueDue;
        bytes data;
        uint8 signaturesCollected;
        bool completed;
    }
    //an array of structs
    Transaction[] public transactionsArray;

    mapping(address => bool) public isSigner;
    mapping(address => bool) public isAdmin;
    //from tx id => owner => bool
    mapping(uint256 => mapping(address => bool)) public txSigned;

    //=======EVENTS=======//

    event WalletSetup(address indexed sender, uint256 value);
    event ReceivedDeposit(address indexed sender, uint256 value);
    event Submission(
        address indexed sender,
        uint256 id,
        address receipient,
        uint256 value,
        bytes data
    );
    event SignedTransaction(address indexed sender, uint256 id);
    event Executed(address indexed sender, uint256 id);
    event SignaturesRequiredForTransaction(
        address indexed sender,
        uint8 signersRequired
    );
    event SetupSignersArray(address indexed sender, address[] signers);

    //=======MODIFIERS=======//

    modifier onlySigners() {
        require(isSigner[msg.sender], "Not a signer");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Not an admin");
        _;
    }

    //=======CONSTRUCTOR=======//

    /**
     * @dev Can pass any address to be admin, not just msg.sender
     */
    constructor(address _admin, uint8 _signaturesRequired) {
        isAdmin[_admin] = true;
        signaturesRequired = _signaturesRequired;
        emit WalletSetup(_admin, _signaturesRequired);
    }

    //=======FALLBACK FUNCTION=======//

    /**
     * @dev fallback function to receive any ether sent and emit an event indicating such.
     */
    receive() external payable {
        emit ReceivedDeposit(msg.sender, msg.value);
    }

    //=======TRANSACTION FUNCTIONs=======//

    /**
     * @dev Submit a transaction to the wallet for consideration
     */
    function submitTransaction(
        address _to,
        uint256 _valueDue,
        bytes memory _data
    ) external onlySigners onlyAdmin {
        uint256 transactionId = transactionsArray.length;

        transactionsArray.push(
            Transaction({
                recipient: _to,
                valueDue: _valueDue,
                data: _data,
                signaturesCollected: 0,
                completed: false
            })
        );

        emit Submission(msg.sender, transactionId, _to, _valueDue, _data);
    }

    /**
     * @dev Sign a transaction that has been submitted for consideration
     */
    function signTransaction(uint256 _transactionId)
        external
        onlySigners
        onlyAdmin
    {
        Transaction storage transaction = transactionsArray[_transactionId];
        transaction.signaturesCollected += 1;
        txSigned[_transactionId][msg.sender] = true;

        emit SignedTransaction(msg.sender, _transactionId);
    }

    /**
     * @dev Get information about a transaction
     */
    function getTransaction(uint256 _transactionId)
        external
        view
        onlySigners
        returns (
            address _recipient,
            uint256 _valueDue,
            bytes memory _data,
            uint256 _numSigners,
            bool _completed
        )
    {
        Transaction storage transaction = transactionsArray[_transactionId];

        return (
            transaction.recipient,
            transaction.valueDue,
            transaction.data,
            transaction.signaturesCollected,
            transaction.completed
        );
    }

    //=======ONLY ADMIN FUNCTIONS=======//

    /**
     * @dev Execute a transaction that has enough signatures.
     */
    function executeTransaction(uint256 _transactionId) external onlyAdmin {
        Transaction storage transaction = transactionsArray[_transactionId];

        require(
            transaction.signaturesCollected >= signaturesRequired,
            "Not enough signatures for approval"
        );

        transaction.completed = true;

        (bool success, ) = transaction.recipient.call{
            value: transaction.valueDue
        }("");
        require(success, "Failed");

        emit Executed(msg.sender, _transactionId);
    }

    /**
     * @dev The admin can change the number of signatures required to execute a transaction
     */
    function addSignaturesRequired(uint8 _signaturesRequired)
        external
        onlyAdmin
    {
        require(
            _signaturesRequired > 0 && _signaturesRequired <= 256,
            "Setup: No. of signers required is incorrect"
        );

        signaturesRequired = _signaturesRequired;

        emit SignaturesRequiredForTransaction(msg.sender, signaturesRequired);
    }

    /**
     * @dev The admin can setup an array of multisig signers
     */
    function setupSignersArray(address[] memory _signers) external onlyAdmin {
        require(
            _signers.length > 0 && _signers.length <= 256,
            "Setup: No. signers incorect"
        );

        for (uint8 i; i < _signers.length; i++) {
            address newSigner = _signers[i];

            if (newSigner == address(0)) {
                revert("Setup: Don't use address(0)");
            } else if (isSigner[newSigner]) {
                revert("Setup: Already a signer");
            } else {
                signers.push(newSigner);
                isSigner[newSigner] = true;
            }
        }

        emit SetupSignersArray(msg.sender, _signers);
    }

    /**
     * @dev The admin can add signers to the multisig
     */
    function addSignerToArray(address _newSigner) external onlyAdmin {
        require(
            !isSigner[_newSigner] && _newSigner != address(0),
            "Cannot add signer"
        );

        signers.push(_newSigner);
        isSigner[_newSigner] = true;
    }

    /**
     * @dev The admin can remove signers from the array and, thus, the multisig
     */
    function removeSigner(address _badSigner) external onlyAdmin {
        require(isSigner[_badSigner], "Not a signer");

        //cast address to uint so delete can be used
        uint256 badSignerId = uint256(uint160(_badSigner));

        //does not change arr length, resets arr value to default value
        delete signers[badSignerId];
    }

    /**
     * @dev The admin can add admins to the wallet
     */
    function addAdmin(address _newAdmin) external onlyAdmin {
        require(
            !isAdmin[_newAdmin] && _newAdmin != address(0),
            "Cannot add admin"
        );
        isAdmin[_newAdmin] = true;
    }

    //=======VIEW FUNCTIONS=======//

    /**
     * @dev Returns the array of multisig signers
     */
    function getSignersArray() external view returns (address[] memory) {
        return signers;
    }
}
