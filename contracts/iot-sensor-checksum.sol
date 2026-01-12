// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// The following contract stores in a blockchain a a checksum reference of the data
contract IotSensorDataCheckSum {

    // Defines the owner for the data transaction.
    address public owner;

    // Total of records stored so far
    uint256  public recordCount;

    // Contract event to be triggered when a new system measurement is registered.
    event NewMeasurementRecord(
        uint256 indexed timestamp,
        bytes32 indexed dataHash,
        uint256 indexed dataEntryPk,
        bytes32 device,
        address source,
        uint256 availableStock
    );

    event lowInventoryEvent(
        uint256 indexed timestamp,
        bytes32 indexed device,
        address source,
        uint256 amountUsed,
        uint256 thresholdAmount
    );

    uint256 private constant inventoryStockAmountThreshold = 10000; // Minimum volume threshold to consider low inventory in liters x.

    constructor() {
        owner = msg.sender;
    }

    // Guard that guarantees certain actions are only executed by contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Action only allowed by owner"); // Verify message sender is owner
        _; // Execute requested method
    }

    // Add a new measurement to the history and register the data in the blockchain.
    function addMeasurement(
        bytes32 _device,
        bytes32 _dataHash,
        uint256 _dataEntryPk,
        uint256 _availableStock
    ) external onlyOwner {
        recordCount++;

        // Event that notifies listeners of new data being registered.
        emit NewMeasurementRecord(
            block.timestamp,
            _dataHash,
            _dataEntryPk,
            _device,
            msg.sender,
            _availableStock
        );

        if (_availableStock < inventoryStockAmountThreshold) {
            // Event that notifies when stock is below admitted threshold
            emit lowInventoryEvent(
                block.timestamp,
                _device,
                msg.sender,
                _availableStock,
                inventoryStockAmountThreshold
            );
        }
    }

    // Returns total records stored in measurement history.
    function getMeasurementRecordCount() external view returns (uint256) {
        return recordCount;
    }
}
