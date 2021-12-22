// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./EIP1967/EIP1967Reader.sol";

/**
 * An entry point to the set of this product contracts. It reuses OpenZeppelin's
 * `Proxy` contract implementation (see https://docs.openzeppelin.com/contracts/4.x/api/proxy#Proxy)
 * to pass the calls to the implementation contract.
 *
 * Implementation contract's address is stored in a pseudo random storage slot,
 * as defined by the EIP-1967 (see http://eips.ethereum.org/EIPS/eip-1967).
 *
 * This proxy contract expects an actual implementation address to be provided
 * to the constructor, and calls this implementation's `initialize()`
 * function in its scope during deploy.
 */
contract ToonTokenProxy is EIP1967Reader, Proxy {
    /**
     * Sets the `implementationAddress` the fallback calls should be delegated to,
     * and immediately calls its `initialize()` method using EVM instruction
     * `delegateCall`.
     */
    constructor(address implementationAddress) {
        // copied'n'pasted from EIP1967Writer._setImplementation
        require(
            Address.isContract(implementationAddress),
            "implementation is not a contract"
        );

        StorageSlot
            .getAddressSlot(_IMPLEMENTATION_SLOT)
            .value = implementationAddress;

        // copied'n'pasted from EIP1967Writer._initializeImplementation
        bytes memory data = abi.encodePacked(_INITIALIZE_CALL);
        Address.functionDelegateCall(implementationAddress, data);
    }

    /**
     * Returns the address to which the fallback calls should be delegated to.
     */
    function implementation() external view returns (address) {
        return _implementationAddress();
    }

    /**
     * See `Proxy._implementation()`
     */
    function _implementation() internal view override returns (address) {
        return _implementationAddress();
    }
}

// Copyright 2021 ToonCoin.COM
// http://tooncoin.com/license
// Full source code: http://tooncoin.com/sourcecode
