//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RideSharing {
    struct Ride {
        uint256 rideId;
        address driver;
        string startLocation;
        string endLocation;
        uint256 availableSeats;
        uint256 pricePerSeat;
        bool isActive;
        mapping(address => uint256) passengers;
    }
    address payable owner;
    uint256 private rideCounter;
    mapping(uint256 => Ride) public rides;

    event RideCreated(
        uint256 indexed rideId,
        address indexed driver,
        string startLocation,
        string endLocation,
        uint256 availableSeats,
        uint256 pricePerSeat
    );
    event RideBooked(
        uint256 indexed rideId,
        address indexed passenger,
        uint256 numSeats
    );

    constructor() {
        owner = payable(msg.sender);
    }

    function createRide(
        string memory _startLocation,
        string memory _endLocation,
        uint256 _availableSeats,
        uint256 _pricePerSeat
    ) public {
        require(_availableSeats > 0, "At least 1 available seat is required");
        require(_pricePerSeat > 0, "Price per seat must be greater than 0");

        rideCounter++;
        // rides[rideCounter] = Ride(
        //     rideCounter,
        //     msg.sender,
        //     _startLocation,
        //     _endLocation,
        //     _availableSeats,
        //     _pricePerSeat,
        //     true,
        //     passengers[msg.sender] = numberOfPassengers
        // );

        Ride storage ride = rides[rideCounter];
        // ride.push(Ride({rideId: rideCounter}));
        ride.rideId = rideCounter;
        ride.driver = msg.sender;
        ride.startLocation = _startLocation;
        ride.endLocation = _endLocation;
        ride.availableSeats = _availableSeats;
        ride.pricePerSeat = _pricePerSeat;
        ride.isActive = true;
        ride.passengers[msg.sender]= rideCounter;

        emit RideCreated(
            rideCounter,
            msg.sender,
            _startLocation,
            _endLocation,
            _availableSeats,
            _pricePerSeat
        );
    }

    function bookRide(uint256 _rideId, uint256 _numSeats) public payable {
        require(_numSeats > 0, "At least 1 seat must be booked");
        require(rides[_rideId].isActive, "Ride is not available");
        require(
            rides[_rideId].availableSeats >= _numSeats,
            "Not enough seats available"
        );
        require(
            msg.value == _numSeats * rides[_rideId].pricePerSeat,
            "Insufficient funds"
        );

        rides[_rideId].passengers[msg.sender] += _numSeats;
        rides[_rideId].availableSeats -= _numSeats;

        emit RideBooked(_rideId, msg.sender, _numSeats);
    }

    function getRide(uint256 _rideId)
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        Ride storage ride = rides[_rideId];
        return (
            ride.driver,
            ride.startLocation,
            ride.endLocation,
            ride.availableSeats,
            ride.pricePerSeat,
            ride.isActive
        );
    }

    function getPassengerSeats(uint256 _rideId, address _passenger)
        public
        view
        returns (uint256)
    {
        return rides[_rideId].passengers[_passenger];
    }

    function cancelRide(uint256 _rideId) public {
        require(
            msg.sender == rides[_rideId].driver,
            "Only the driver can cancel a ride"
        );

        rides[_rideId].isActive = false;
    }

    function withdrawFunds() public {
        uint256 balance = address(this).balance;
        require(
            msg.sender == owner,
            "Only the contract owner can withdraw funds"
        );
        require(balance > 0, "No funds available to withdraw");

        payable(msg.sender).transfer(balance);
    }
}
