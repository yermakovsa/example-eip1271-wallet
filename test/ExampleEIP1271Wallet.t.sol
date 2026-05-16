// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";

import {ExampleEIP1271Wallet} from "../src/ExampleEIP1271Wallet.sol";

contract ExampleEIP1271WalletTest is Test {
    uint256 internal constant OWNER_PRIVATE_KEY = 0xA11CE;
    uint256 internal constant WRONG_SIGNER_PRIVATE_KEY = 0xB0B;

    uint256 internal constant TEST_SECP256K1_ORDER = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;

    address internal owner;

    ExampleEIP1271Wallet internal wallet;

    function setUp() public {
        owner = vm.addr(OWNER_PRIVATE_KEY);
        wallet = new ExampleEIP1271Wallet(owner);
    }

    function testConstructorStoresOwner() public view {
        assertEq(wallet.owner(), owner);
    }

    function testConstructorRejectsZeroOwner() public {
        vm.expectRevert(ExampleEIP1271Wallet.ZeroOwner.selector);

        new ExampleEIP1271Wallet(address(0));
    }

    function testValidOwnerSignatureReturnsMagicValue() public view {
        bytes32 hash = keccak256("example hash");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_PRIVATE_KEY, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes4 result = wallet.isValidSignature(hash, signature);

        assertEq(result, wallet.EIP1271_MAGIC_VALUE());
    }

    function testWrongSignerReturnsInvalidValue() public view {
        bytes32 hash = keccak256("example hash");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(WRONG_SIGNER_PRIVATE_KEY, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes4 result = wallet.isValidSignature(hash, signature);

        assertEq(result, wallet.INVALID_SIGNATURE_VALUE());
    }

    function testWrongHashReturnsInvalidValue() public view {
        bytes32 signedHash = keccak256("signed hash");
        bytes32 checkedHash = keccak256("checked hash");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_PRIVATE_KEY, signedHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes4 result = wallet.isValidSignature(checkedHash, signature);

        assertEq(result, wallet.INVALID_SIGNATURE_VALUE());
    }

    function testShortSignatureReturnsInvalidValue() public view {
        bytes32 hash = keccak256("example hash");
        bytes memory shortSignature = hex"1234";

        bytes4 result = wallet.isValidSignature(hash, shortSignature);

        assertEq(result, wallet.INVALID_SIGNATURE_VALUE());
    }

    function testMalformedSignaturesNeverRevert() public view {
        bytes32 hash = keccak256("example hash");

        bytes memory emptySignature = "";
        bytes memory shortSignature = hex"1234";
        bytes memory longSignature = new bytes(66);

        assertEq(wallet.isValidSignature(hash, emptySignature), wallet.INVALID_SIGNATURE_VALUE());
        assertEq(wallet.isValidSignature(hash, shortSignature), wallet.INVALID_SIGNATURE_VALUE());
        assertEq(wallet.isValidSignature(hash, longSignature), wallet.INVALID_SIGNATURE_VALUE());
    }

    function testBadVReturnsInvalidValue() public view {
        bytes32 hash = keccak256("example hash");

        (, bytes32 r, bytes32 s) = vm.sign(OWNER_PRIVATE_KEY, hash);
        uint8 badV = 29;
        bytes memory signature = abi.encodePacked(r, s, badV);

        bytes4 result = wallet.isValidSignature(hash, signature);

        assertEq(result, wallet.INVALID_SIGNATURE_VALUE());
    }

    function testHighSReturnsInvalidValue() public view {
        bytes32 hash = keccak256("example hash");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_PRIVATE_KEY, hash);

        bytes32 highS = bytes32(TEST_SECP256K1_ORDER - uint256(s));
        uint8 flippedV = v == 27 ? 28 : 27;
        bytes memory malleableSignature = abi.encodePacked(r, highS, flippedV);

        bytes4 result = wallet.isValidSignature(hash, malleableSignature);

        assertGt(uint256(highS), wallet.SECP256K1_HALF_ORDER());
        assertEq(result, wallet.INVALID_SIGNATURE_VALUE());
    }

    function testVZeroIsRejected() public view {
        bytes32 hash = keccak256("example hash");

        (, bytes32 r, bytes32 s) = vm.sign(OWNER_PRIVATE_KEY, hash);
        uint8 zeroV = 0;
        bytes memory signature = abi.encodePacked(r, s, zeroV);

        bytes4 result = wallet.isValidSignature(hash, signature);

        assertEq(result, wallet.INVALID_SIGNATURE_VALUE());
    }

    function testVOneIsRejected() public view {
        bytes32 hash = keccak256("example hash");

        (, bytes32 r, bytes32 s) = vm.sign(OWNER_PRIVATE_KEY, hash);
        uint8 oneV = 1;
        bytes memory signature = abi.encodePacked(r, s, oneV);

        bytes4 result = wallet.isValidSignature(hash, signature);

        assertEq(result, wallet.INVALID_SIGNATURE_VALUE());
    }
}
