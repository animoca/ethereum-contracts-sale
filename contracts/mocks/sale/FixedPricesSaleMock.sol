// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {FixedPricesSale} from "../../sale/FixedPricesSale.sol";

contract FixedPricesSaleMock is FixedPricesSale {
    /**
     * Constructor.
     * @dev Emits the `MagicValues` event.
     * @dev Emits the `Paused` event.
     * @param payoutWallet_ the payout wallet.
     * @param skusCapacity the cap for the number of managed SKUs.
     * @param tokensPerSkuCapacity the cap for the number of tokens managed per SKU.
     */
    constructor(
        address payable payoutWallet_,
        uint256 skusCapacity,
        uint256 tokensPerSkuCapacity
    ) FixedPricesSale(payoutWallet_, skusCapacity, tokensPerSkuCapacity) {}

    function createSku(
        bytes32 sku,
        uint256 totalSupply,
        uint256 maxQuantityPerPurchase,
        address notificationsReceiver
    ) external {
        _createSku(sku, totalSupply, maxQuantityPerPurchase, notificationsReceiver);
    }
}
