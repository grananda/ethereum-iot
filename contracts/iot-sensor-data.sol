// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract IotSensorData {
    enum State {
        NORMAL,
        EMPTY,
        CORRUPTED,
        UNDEFINED
    }
    enum Action {
        FILL,
        EMPTY,
        NONE
    }

    struct SystemStateData {
        uint256 timeStamp;
        address source;
        int256 temperature;
        int256 humidity;
        int256 density;
        int256 conductivity;
        int256 weight;
        int256 volume;
        State state;
        Action action;
    }

    address public owner;

    SystemStateData[] public measurementHistory;

    event NewMeasurement(
        uint256 indexed timestamp,
        address indexed source,
        State state,
        Action action,
        uint256 measurementIndex
    );

    constructor() {
        owner = msg.sender;
    }

    // Modifier to validate user identity
    modifier onlyOwner() {
        require(msg.sender == owner, "Action only allowed by owner"); // Verify message sender is owner
        _; // Execute requested method
    }

    function addMeasurement(
        int256 _temperature,
        int256 _humidity,
        int256 _density,
        int256 _conductivity,
        int256 _weight,
        int256 _volume,
        State _state,
        Action _action
    ) public onlyOwner {
        SystemStateData memory newDataEntry = SystemStateData({
            timeStamp: block.timestamp,
            source: msg.sender,
            temperature: _temperature,
            humidity: _humidity,
            density: _density,
            conductivity: _conductivity,
            weight: _weight,
            volume: _volume,
            state: _state,
            action: _action
        });

        measurementHistory.push(newDataEntry);

        emit NewMeasurement(
            block.timestamp,
            msg.sender,
            _state,
            _action,
            measurementHistory.length - 1
        );
    }

    function getMeasurementCount() external view returns (uint256) {
        return measurementHistory.length;
    }

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

    function getMeasurement(
        uint256 index
    ) external view returns (SystemStateData memory) {
        require(
            index < measurementHistory.length,
            "Requested index out of bounds."
        );

        return measurementHistory[index];
    }

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

    function getLastNMeasurements(
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

    function getMeasurementsBetweenDates(
        int256 startTime,
        int256 endTime
    ) external view returns (SystemStateData[] memory) {}

    function getAverageTemperature(int256 n) external view returns (int256) {}

    function getAverageHumidity(int256 n) external view returns (int256) {}

    function getMeasurementsByState(
        State state
    ) external view returns (SystemStateData[] memory) {}

    function deleteMeasurement(int256 index) external onlyOwner {}

    function transferOwnership(address newOwner) external onlyOwner {}
}
