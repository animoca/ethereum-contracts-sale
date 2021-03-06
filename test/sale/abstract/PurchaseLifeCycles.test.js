const {artifacts} = require('hardhat');
const {ether} = require('@openzeppelin/test-helpers');
const {Zero, One, ZeroAddress} = require('@animoca/ethereum-contracts-core').constants;
const {stringToBytes32} = require('../../utils/bytes32');

const PurchaseLifeCycles = artifacts.require('PurchaseLifeCyclesMock');
const ERC20 = artifacts.require('ERC20Mock');

const sku = stringToBytes32('sku');
const quantity = One;
const tokenSupply = ether('1000000000');
const userData = '0x00';

let _, owner, purchaser, recipient;

describe('PurchaseLifeCycles', function () {
  before(async function () {
    [_, owner, payoutWallet, purchaser, recipient] = await web3.eth.getAccounts();
  });

  beforeEach(async function () {
    this.contract = await PurchaseLifeCycles.new({from: owner});
    const registry = await artifacts.require('ForwarderRegistry').new();
    const forwarder = await artifacts.require('UniversalForwarder').new();
    this.token = await ERC20.new([owner], [tokenSupply], registry.address, forwarder.address, {from: owner});
  });

  describe('_estimatePurchase()', function () {
    beforeEach(async function () {
      await this.contract.getEstimatePurchaseLifeCyclePath(recipient, this.token.address, sku, quantity, userData, {from: purchaser});
      const events = await this.contract.getPastEvents('PurchaseLifeCyclePath', {fromBlock: 'latest'});
      this.lifeCyclePath = events[0].args.path;
    });

    it('should call _validation()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_VALIDATION();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(lifeCycleStep);
    });

    it('should call _pricing()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_PRICING();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(lifeCycleStep);
    });

    it('should not call _payment()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_PAYMENT();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(Zero);
    });

    it('should not call _delivery()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_DELIVERY();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(Zero);
    });

    it('should not call _notification()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_NOTIFICATION();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(Zero);
    });
  });

  describe('_purchaseFor()', function () {
    beforeEach(async function () {
      await this.contract.getPurchaseForLifeCyclePath(recipient, this.token.address, sku, quantity, userData, {from: purchaser});
      const events = await this.contract.getPastEvents('PurchaseLifeCyclePath', {fromBlock: 'latest'});
      this.lifeCyclePath = events[0].args.path;
    });

    it('should call _validation()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_VALIDATION();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(lifeCycleStep);
    });

    it('should call _pricing()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_PRICING();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(lifeCycleStep);
    });

    it('should call _payment()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_PAYMENT();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(lifeCycleStep);
    });

    it('should call _delivery()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_DELIVERY();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(lifeCycleStep);
    });

    it('should call _notification()', async function () {
      const lifeCycleStep = await this.contract.LIFECYCLE_STEP_NOTIFICATION();
      this.lifeCyclePath.and(lifeCycleStep).should.be.bignumber.equal(lifeCycleStep);
    });
  });
});
