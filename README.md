# example-eip1271-wallet

Small public fixture for EIP-1271 tests and examples.

It is not a production wallet.

## Contract

`ExampleEIP1271Wallet` stores one immutable owner and implements:

```solidity
function isValidSignature(bytes32 hash, bytes calldata signature)
    external
    view
    returns (bytes4)
````

It validates a standard 65-byte ECDSA signature against the raw `bytes32` hash passed by the caller.

It does not prefix, hash, or reinterpret the message.

Return values:

```text
valid:   0x1626ba7e
invalid: 0xffffffff
```

## Sepolia fixture

```text
chain: Sepolia
contract address: 0x01719b210cca35ee34f46007daed7fb359086f91
etherscan: https://sepolia.etherscan.io/address/0x01719b210cca35ee34f46007daed7fb359086f91#code
owner address: 0x3c002f761491bea2b25A8321490f9ca7A87B4DCf
hash: 0x3dec0f6a98cd6082f478ae1d655bf12eb7c2c52be60e011c91a5ae1f62670b5c
signature: 0xae49e3481e4a9f5c59d78d3e47efd9cc5975e0c0678243202846eb9e43230e02425fe69fd882ccec3a76e13d25a542b58a33ef24c5a8a8186778d7e13c87ca671c
expected result: 0x1626ba7e
```

The deployer and owner private keys are not included in this repo.

## Verify

```bash
cast call 0x01719b210cca35ee34f46007daed7fb359086f91 \
  "isValidSignature(bytes32,bytes)(bytes4)" \
  0x3dec0f6a98cd6082f478ae1d655bf12eb7c2c52be60e011c91a5ae1f62670b5c \
  0xae49e3481e4a9f5c59d78d3e47efd9cc5975e0c0678243202846eb9e43230e02425fe69fd882ccec3a76e13d25a542b58a33ef24c5a8a8186778d7e13c87ca671c \
  --rpc-url "$SEPOLIA_RPC_URL"
```

Expected output:

```text
0x1626ba7e
```

## Development

```bash
forge test
forge build
```

## Deploy

Set:

```bash
OWNER_ADDRESS=0x...
SEPOLIA_RPC_URL=...
DEPLOYER_PRIVATE_KEY=0x...
```

Then run:

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$DEPLOYER_PRIVATE_KEY" \
  --broadcast
```

Never commit private keys.

## License

MIT
