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

    SystemStateData systemStateData;

    event NewMeasurement(
        uint256 indexed timestamp,
        address indexed source,
        State state,
        Action action,
        uint256 measurementIndex
    );

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
            measurementHistory.length - 1
        );
    }
}
