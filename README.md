# Multi Signature Wallet

This MultiSigWallet has two access levels: admins and signers.

Admins can add or remove signers and admins as well as submit, sign, and execute transactions.

Signers can only submit and sign transactions.

## On Testing

Tests written in Solidity. Tested both admin, signer, and foreign address access. Also tested submit, sign, and execution of transactions.

Built with [dapp.tools](https://dapp.tools/).

## References

### General MultiSigWallet knowledge

- [Gnosis Safe](https://github.com/gnosis/safe-contracts/blob/main/contracts/GnosisSafe.sol)

- [Solidity-by-example](https://solidity-by-example.org/app/multi-sig-wallet/)

- [Simple MultiSig](https://github.com/christianlundkvist/simple-multisig)

### Great resources for testing with dapp.tools

- [Rari Capital Vault Tests](https://github.com/Rari-Capital/vaults/blob/main/src/test/Vault.t.sol)

- [Refelxer Labs Tests](https://github.com/reflexer-labs/geb/blob/master/src/test/single/SingleDebtAuctionHouse.t.sol)

- [Zora](https://github.com/ourzora/v3/tree/main/contracts/test)