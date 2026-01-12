// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// The following contract stores in a blockchain a set of data related to the physical state of a chemical reactive or substance.
contract IotSensorData {
    // Enum structure that defines the state of the system at data collection time.
    enum State {
        NORMAL,
        EMPTY,
        CORRUPTED,
        UNDEFINED
    }

    // Enum structure that defines if an action was taken at data collection time.
    enum Action {
        FILL,
        EMPTY,
        NONE
    }

    // Structure that defines the data defining the state of the system at a specific time.
    // All data values are represented as integer and must be divided by 100 to obtain the correct float value.
    struct SystemStateData {
        uint256 timeStamp; // Time for data collection
        address source; // Device ID for the reported data
        int256 temperature; // System temperature in Celsius
        uint256 density; // Substance density in g/L
        int256 conductivity; // Substance conductivity in uS/cm
        uint256 weight; // Substance weight in grams
        uint256 volume; // Substance volume in liters
        uint256 ph; // Substance pH
        uint256 color; // Substance color as RGB code
        uint256 availableStock; // Available stock in liters
        State state; // Current state of the system
        Action action; // Action taken in relation to current system state
    }

    // Defines the owner for the data transaction.
    address public owner;

    // Data structure to hold all registered measurements.
    SystemStateData[] public measurementHistory;

    // Contract event to be triggered when a new system measurement is registered.
    event NewMeasurement(
        uint256 indexed timestamp,
        address indexed source,
        State state,
        Action action,
        uint256 measurementIndex
    );

    event lowInventoryEvent(
        uint256 amountUsed,
        uint256 thresholdAmount,
        uint256 indexed timestamp,
        uint256 indexed index
    );

    uint256 private constant inventoryStockAmountThreshold = 100; // Minimum volume threshold to consider low inventory in liters.

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
        int256 _temperature,
        uint256 _density,
        int256 _conductivity,
        uint256 _weight,
        uint256 _volume,
        uint256 _ph,
        uint256 _color,
        uint256 _availableStock,
        State _state,
        Action _action
    ) public onlyOwner {
        SystemStateData memory newDataEntry = SystemStateData({
            timeStamp: block.timestamp,
            source: msg.sender,
            temperature: _temperature,
            density: _density,
            conductivity: _conductivity,
            weight: _weight,
            volume: _volume,
            ph: _ph,
            color: _color,
            availableStock: _availableStock,
            state: _state,
            action: _action
        });

        measurementHistory.push(newDataEntry); // Data is registered in the blockchain.

        // Event that notifies listeners of new data being registered.
        emit NewMeasurement(
            block.timestamp,
            msg.sender,
            _state,
            _action,
            measurementHistory.length - 1
        );

        if (_availableStock < inventoryStockAmountThreshold) {
            // Event that notifies when stock is below admitted threshold
            emit lowInventoryEvent(
                _availableStock,
                inventoryStockAmountThreshold,
                block.timestamp,
                measurementHistory.length - 1
            );
        }
    }

    // Returns total records stored in measurement history.
    function getMeasurementCount() external view returns (uint256) {
        return measurementHistory.length;
    }

    // Returns last record stored in measurement history.
    function getLastMeasurement()
        external
        view
        returns (SystemStateData memory)
    {
        require(
            measurementHistory.length > 0,
            "No available measurements to work with."
        );

        return measurementHistory[measurementHistory.length - 1];
    }

    // Returns specific record by index stored in measurement history.
    function getMeasurement(
        uint256 index
    ) external view returns (SystemStateData memory) {
        require(
            index < measurementHistory.length,
            "Requested index out of bounds."
        );

        return measurementHistory[index];
    }

    // Returns first N records stored in measurement history.
    function getFirstNMeasurements(
        uint256 n
    ) external view returns (SystemStateData[] memory) {
        uint256 count = n > measurementHistory.length
            ? measurementHistory.length
            : n;

        SystemStateData[] memory res = new SystemStateData[](count);

        for (uint256 i = 0; i < count; i++) {
            res[i] = measurementHistory[i];
        }

        return res;
    }

    // Returns last N records stored in measurement history.
    function getLastNMeasurements(
        uint256 n
    ) external view returns (SystemStateData[] memory) {
        uint256 count = n > measurementHistory.length
            ? measurementHistory.length
            : n;

        SystemStateData[] memory res = new SystemStateData[](count);

        uint256 startIndex = measurementHistory.length - count;

        for (uint256 i = 0; i < count; i++) {
            res[i] = measurementHistory[startIndex + i];
        }

        return res;
    }

    // Returns all records stored between certain dates in measurement history.
    function getMeasurementsBetweenDates(
        uint256 startTime,
        uint256 endTime
    ) external view returns (SystemStateData[] memory) {
        require(startTime <= endTime, "Invalid time range.");

        uint256 count = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) count++;
        }

        SystemStateData[] memory res = new SystemStateData[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                res[index] = measurementHistory[i];
                index++;
            }
        }

        return res;
    }

    // Returns average temperature between certain dates in measurement history.
    function getAverageTemperature(
        uint256 startTime,
        uint256 endTime
    ) external view returns (int256) {
        require(startTime <= endTime, "Invalid time range.");

        int256 count = 0;
        int256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].temperature;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        int256 average = acc / count;

        return average;
    }

    // Returns average conductivity between certain dates in measurement history.
    function getAverageConductivity(
        uint256 startTime,
        uint256 endTime
    ) external view returns (int256) {
        int256 count = 0;
        int256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].conductivity;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        int256 average = acc / count;

        return average;
    }

    // Returns average density between certain dates in measurement history.
    function getAverageDensity(
        uint256 startTime,
        uint256 endTime
    ) external view returns (uint256) {
        uint256 count = 0;
        uint256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].density;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        uint256 average = acc / count;

        return average;
    }

    // Returns average weight between certain dates in measurement history.
    function getAverageWeight(
        uint256 startTime,
        uint256 endTime
    ) external view returns (uint256) {
        uint256 count = 0;
        uint256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].weight;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        uint256 average = acc / count;

        return average;
    }

    // Returns average volume between certain dates in measurement history.
    function getAverageVolume(
        uint256 startTime,
        uint256 endTime
    ) external view returns (uint256) {
        uint256 count = 0;
        uint256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].volume;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        uint256 average = acc / count;

        return average;
    }

    // Returns average ph between certain dates in measurement history.
    function getAveragePH(
        uint256 startTime,
        uint256 endTime
    ) external view returns (uint256) {
        uint256 count = 0;
        uint256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].ph;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        uint256 average = acc / count;

        return average;
    }

    // Returns average color between certain dates in measurement history.
    function getAverageColor(
        uint256 startTime,
        uint256 endTime
    ) external view returns (uint256) {
        uint256 count = 0;
        uint256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].color;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        uint256 average = acc / count;

        return average;
    }

    // Returns all records by state between certain dates in measurement history.
    function getMeasurementsByState(
        State state,
        uint256 startTime,
        uint256 endTime
    ) external view returns (SystemStateData[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (
                measurementHistory[i].state == state &&
                timeStamp >= startTime &&
                timeStamp <= endTime
            ) count++;
        }

        SystemStateData[] memory res = new SystemStateData[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (
                measurementHistory[i].state == state &&
                timeStamp >= startTime &&
                timeStamp <= endTime
            ) {
                res[index] = measurementHistory[i];
                index++;
            }
        }

        return res;
    }

    // Returns all records by action taken between certain dates in measurement history.
    function getMeasurementsByAction(
        Action action,
        uint256 startTime,
        uint256 endTime
    ) external view returns (SystemStateData[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (
                measurementHistory[i].action == action &&
                timeStamp >= startTime &&
                timeStamp <= endTime
            ) count++;
        }

        SystemStateData[] memory res = new SystemStateData[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (
                measurementHistory[i].action == action &&
                timeStamp >= startTime &&
                timeStamp <= endTime
            ) {
                res[index] = measurementHistory[i];
                index++;
            }
        }

        return res;
    }
}
