// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/**
 * @dev This is a multi-signature wallet that separates signers from admins.
 */
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
    //an array of structs
    Transaction[] public transactionsArray;

    //grant the admin signer level
    bytes32 public constant ADMIN_SIGNER_LEVEL =
        keccak256(abi.encodePacked("ADMIN_SIGNER_LEVEL"));

    //level => account => bool
    mapping(bytes32 => mapping(address => bool)) public isAdmin;
    mapping(address => bool) public isSigner;

    event WalletSetup(address indexed sender);
    event ReceivedDeposit(address indexed sender, uint256 value);
    event Submission(
        address indexed sender,
        uint256 id,
        address receipient,
        uint256 value,
        bytes data
    );
    event Executed(address indexed sender, uint256 id);
    event SignaturesRequiredForTransaction(
        address indexed sender,
        uint8 signersRequired
    );
    event SetupSignersArray(address indexed sender, address[] signers);

    //=======MODIFIERS=======

    modifier onlySigners() {
        require(isSigner[msg.sender], "Not an owner");
        _;
    }

    modifier onlyAdmin(bytes32 _signerLevel) {
        require(isAdmin[_signerLevel][msg.sender], "Not an Admin");
        _;
    }

    //=======CONSTRUCTOR=======

    constructor() {
        grantAdminLevelOnSetup(ADMIN_SIGNER_LEVEL, msg.sender);

        emit WalletSetup(msg.sender);
    }

    //=======FUNCTIONS=======

    /**
     * @dev fallback function to receive any ether sent and emit an event indicating such.
     */
    receive() external payable {
        emit ReceivedDeposit(msg.sender, msg.value);
    }

    /**
     * @dev Called on setup, granting an admin role.
     */
    function grantAdminLevelOnSetup(bytes32 _adminLevel, address _signerAccount)
        internal
    {
        isAdmin[_adminLevel][_signerAccount] = true;
    }

    /**
     * @dev Grant an admin role after setup
     */
    function grantAdminLevel(bytes32 _adminLevel, address _signerAccount)
        public
        onlyAdmin(ADMIN_SIGNER_LEVEL)
    {
        isAdmin[_adminLevel][_signerAccount] = true;
    }

    /**
     * @dev Submit a transaction to the multisig for consideration
     */
    function submitTransaction(
        address _to,
        uint256 _valueDue,
        bytes memory _data
    ) public onlySigners {
        uint256 transactionId = transactionsArray.length;

        transactionsArray.push(
            Transaction({
                recipient: _to,
                valueDue: _valueDue,
                data: _data,
                numSigners: 0,
                completed: false
            })
        );

        emit Submission(msg.sender, transactionId, _to, _valueDue, _data);
    }

    /**
     * @dev Execute a transaction that has already been submitted to the multisig
     */
    function executeTransaction(uint256 _transactionId) public onlySigners {
        Transaction storage transaction = transactionsArray[_transactionId];
        transaction.numSigners += 1;

        require(
            transaction.numSigners >= signaturesRequired,
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
     * @dev Get data on a transaction
     */
    function getTransaction(uint256 _transactionId)
        public
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
            transaction.numSigners,
            transaction.completed
        );
    }

    /**
     * @dev The admin can change the number of signatures required to execute a transaction
     */
    function signaturesRequiredForTx(uint8 _signaturesRequired)
        public
        onlyAdmin(ADMIN_SIGNER_LEVEL)
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
    function setupSignersArray(address[] memory _signers)
        public
        onlyAdmin(ADMIN_SIGNER_LEVEL)
    {
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
    function addSignerToArray(address _newSigner)
        public
        onlyAdmin(ADMIN_SIGNER_LEVEL)
    {
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
    function removeSigner(address _badSigner)
        public
        onlyAdmin(ADMIN_SIGNER_LEVEL)
    {
        require(isSigner[_badSigner], "Not a signer");

        //cast address to uint so delete can be used
        uint256 badSignerId = uint256(uint160(_badSigner));

        //does not change arr length, resets arr value to default value
        delete signers[badSignerId];
    }

    /**
     * @dev Returns the array of multisig signers
     */
    function getSignersArray() public view returns (address[] memory) {
        return signers;
    }
}
