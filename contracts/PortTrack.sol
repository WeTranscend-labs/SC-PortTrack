// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipJourneyTracker {

    struct Port {
        uint256 id;
        string name;
        string location;
        string portAddress;
        string representative;
        string country;
        string portCode;
        uint256 registeredAt; 
    }

    struct Ship {
        uint256 id;
        string name;
        string owner;
        string shipCode;
        string registryCountry;
        string shipType;
        uint256 length;
        uint256 width;
        uint256 capacity;
        string engineType;
        uint256 registeredAt; 
        bool isActive;
    }

    struct Journey {
        uint256 id;
        uint256 shipId;
        uint256 startPortId; 
        uint256[] portIds; 
        uint256[] arrivalTimes; 
        string[] notes; 
        bool completed;
    }

    mapping(uint256 => Ship) public ships;
    mapping(uint256 => Port) public ports;
    mapping(uint256 => Journey) public journeys;

    uint256 private nextShipId = 1;
    uint256 private nextPortId = 1;
    uint256 private nextJourneyId = 1;

    event ShipRegistered(uint256 shipId, string name);
    event PortRegistered(uint256 portId, string name);
    event JourneyStarted(uint256 journeyId, uint256 shipId, uint256 startPortId);
    event PortVisited(uint256 journeyId, uint256 portId, uint256 arrivalTime, string note);
    event JourneyCompleted(uint256 journeyId);

    function registerShip(
        string memory name,
        string memory owner,
        string memory shipCode,
        string memory registryCountry,
        string memory shipType,
        uint256 length,
        uint256 width,
        uint256 capacity,
        string memory engineType
    ) public {
        ships[nextShipId] = Ship({
            id: nextShipId,
            name: name,
            owner: owner,
            shipCode: shipCode,
            registryCountry: registryCountry,
            shipType: shipType,
            length: length,
            width: width,
            capacity: capacity,
            engineType: engineType,
            registeredAt: block.timestamp,
            isActive: true
        });

        emit ShipRegistered(nextShipId, name);
        nextShipId++;
    }

    function registerPort(
        string memory name,
        string memory location,
        string memory portAddress,
        string memory representative,
        string memory country,
        string memory portCode
    ) public {
        ports[nextPortId] = Port({
            id: nextPortId,
            name: name,
            location: location,
            portAddress: portAddress,
            representative: representative,
            country: country,
            portCode: portCode,
            registeredAt: block.timestamp
        });

        emit PortRegistered(nextPortId, name);
        nextPortId++;
    }

    function startJourney(uint256 shipId, uint256 startPortId) public {
        require(ships[shipId].isActive, "Ship is not active");
        require(ports[startPortId].id != 0, "Start port does not exist");

        journeys[nextJourneyId] = Journey({
            id: nextJourneyId,
            shipId: shipId,
            startPortId: startPortId,
            portIds: new uint256[](0),   
            arrivalTimes: new uint256[](0), 
            notes: new string[](0),       
            completed: false
        });

        emit JourneyStarted(nextJourneyId, shipId, startPortId);
        nextJourneyId++;
    }


    function visitPort(uint256 journeyId, uint256 portId, string memory note) public {
        Journey storage journey = journeys[journeyId];
        require(!journey.completed, "Journey already completed");
        require(ports[portId].id != 0, "Port does not exist");

        journey.portIds.push(portId);
        journey.arrivalTimes.push(block.timestamp);
        journey.notes.push(note);

        emit PortVisited(journeyId, portId, block.timestamp, note);
    }

    function completeJourney(uint256 journeyId) public {
        Journey storage journey = journeys[journeyId];
        require(!journey.completed, "Journey already completed");

        journey.completed = true;

        emit JourneyCompleted(journeyId);
    }

    function getShips() public view returns (Ship[] memory) {
        Ship[] memory shipList = new Ship[](nextShipId - 1); 

        for (uint256 i = 1; i < nextShipId; i++) {
            shipList[i - 1] = ships[i]; 
        }

        return shipList;
    }

    function getJourney(uint256 journeyId) public view returns (
        uint256 shipId,
        uint256 startPortId,
        uint256[] memory portIds,
        uint256[] memory arrivalTimes,
        string[] memory notes,
        bool completed
    ) {
        Journey storage journey = journeys[journeyId];
        return (
            journey.shipId,
            journey.startPortId,
            journey.portIds,
            journey.arrivalTimes,
            journey.notes,
            journey.completed
        );
    }
}
