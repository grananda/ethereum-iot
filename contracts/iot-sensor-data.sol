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

        uint256 startIndex = measurementHistory.length - count;

        for (uint256 i = 0; i < count; i++) {
            res[i] = measurementHistory[startIndex + i];
        }

        return res;
    }

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

    function getAverageHumidity(
        uint256 startTime,
        uint256 endTime
    ) external view returns (int256) {
        int256 count = 0;
        int256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].humidity;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        int256 average = acc / count;

        return average;
    }

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

    function getAverageDensity(
        uint256 startTime,
        uint256 endTime
    ) external view returns (int256) {
        int256 count = 0;
        int256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].density;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        int256 average = acc / count;

        return average;
    }

    function getAverageWeight(
        uint256 startTime,
        uint256 endTime
    ) external view returns (int256) {
        int256 count = 0;
        int256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].weight;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        int256 average = acc / count;

        return average;
    }

    function getAverageVolume(
        uint256 startTime,
        uint256 endTime
    ) external view returns (int256) {
        int256 count = 0;
        int256 acc = 0;

        for (uint256 i = 0; i < measurementHistory.length; i++) {
            uint256 timeStamp = measurementHistory[i].timeStamp;
            if (timeStamp >= startTime && timeStamp <= endTime) {
                acc += measurementHistory[i].volume;
                count++;
            }
        }

        require(count > 0, "No available measurements");

        int256 average = acc / count;

        return average;
    }

    function getMeasurementsByState(
        State state
    ) external view returns (SystemStateData[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            if (measurementHistory[i].state == state) count++;
        }

        SystemStateData[] memory res = new SystemStateData[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            if (measurementHistory[i].state == state) {
                res[index] = measurementHistory[i];
                index++;
            }
        }

        return res;
    }

    function getMeasurementsByAction(
        Action action
    ) external view returns (SystemStateData[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            if (measurementHistory[i].action == action) count++;
        }

        SystemStateData[] memory res = new SystemStateData[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < measurementHistory.length; i++) {
            if (measurementHistory[i].action == action) {
                res[index] = measurementHistory[i];
                index++;
            }
        }

        return res;
    }
}
