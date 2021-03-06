// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {EnumSet, EnumMap, Sale} from "../../sale/abstract/Sale.sol";

contract SaleMock is Sale {
    using EnumSet for EnumSet.Set;
    using EnumMap for EnumMap.Map;

    event PurchaseForCalled(address payable recipient, address token, bytes32 sku, uint256 quantity, bytes userData);

    constructor(
        address payable payoutWallet_,
        uint256 skusCapacity,
        uint256 tokensPerSkuCapacity
    ) Sale(payoutWallet_, skusCapacity, tokensPerSkuCapacity) {}

    function setPaused(bool paused) external {
        if (paused) {
            _pause();
        } else {
            _unpause();
        }
    }

    function createSku(
        bytes32 sku,
        uint256 totalSupply,
        uint256 maxQuantityPerPurchase,
        address notificationsReceiver
    ) external {
        _createSku(sku, totalSupply, maxQuantityPerPurchase, notificationsReceiver);
    }

    function setTokenPrices(
        bytes32 sku,
        address[] calldata tokens,
        uint256[] calldata prices
    ) external {
        SkuInfo storage skuInfo = _skuInfos[sku];
        EnumMap.Map storage tokenPrices = skuInfo.prices;
        _setTokenPrices(tokenPrices, tokens, prices);
    }

    function validation(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData,
        uint256 totalPrice,
        bytes32[] calldata pricingData,
        bytes32[] calldata paymentData,
        bytes32[] calldata deliveryData
    ) external view {
        PurchaseData memory purchaseData = _getPurchaseData(
            recipient,
            token,
            sku,
            quantity,
            userData,
            totalPrice,
            pricingData,
            paymentData,
            deliveryData
        );

        _validation(purchaseData);
    }

    function delivery(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData,
        uint256 totalPrice,
        bytes32[] calldata pricingData,
        bytes32[] calldata paymentData,
        bytes32[] calldata deliveryData
    ) external {
        PurchaseData memory purchaseData = _getPurchaseData(
            recipient,
            token,
            sku,
            quantity,
            userData,
            totalPrice,
            pricingData,
            paymentData,
            deliveryData
        );

        _delivery(purchaseData);
    }

    function notification(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData,
        uint256 totalPrice,
        bytes32[] calldata pricingData,
        bytes32[] calldata paymentData,
        bytes32[] calldata deliveryData
    ) external {
        PurchaseData memory purchaseData = _getPurchaseData(
            recipient,
            token,
            sku,
            quantity,
            userData,
            totalPrice,
            pricingData,
            paymentData,
            deliveryData
        );

        _notification(purchaseData);
    }

    function _pricing(PurchaseData memory purchase) internal view override {
        SkuInfo storage skuInfo = _skuInfos[purchase.sku];
        bytes32 key = bytes32(uint256(purchase.token));
        bytes32 value = skuInfo.prices.get(key);
        uint256 price = uint256(value);
        purchase.totalPrice = purchase.quantity * price;
    }

    function _payment(
        PurchaseData memory /*purchase*/
    ) internal override {}

    function _getPurchaseData(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes memory userData,
        uint256 totalPrice,
        bytes32[] memory pricingData,
        bytes32[] memory paymentData,
        bytes32[] memory deliveryData
    ) internal view returns (PurchaseData memory purchase) {
        purchase.purchaser = _msgSender();
        purchase.recipient = recipient;
        purchase.token = token;
        purchase.sku = sku;
        purchase.quantity = quantity;
        purchase.userData = userData;
        purchase.totalPrice = totalPrice;
        purchase.pricingData = pricingData;
        purchase.paymentData = paymentData;
        purchase.deliveryData = deliveryData;
    }
}
