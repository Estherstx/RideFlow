# RideFlow 🚗

A decentralized ride-sharing platform built on the Stacks blockchain using Clarity smart contracts.

## Overview

RideFlow revolutionizes transportation by creating a trustless, decentralized ride-sharing ecosystem where riders and drivers can connect directly without intermediaries. Built on Bitcoin's security through Stacks, RideFlow ensures transparent, secure, and efficient ride management.

## Features

- **Decentralized Ride Matching**: Direct connection between riders and drivers
- **Transparent Pricing**: Fair fare calculation with minimal platform fees
- **Rating System**: Built-in reputation system for quality assurance
- **Secure Payments**: Blockchain-based payment processing
- **Real-time Status Tracking**: Complete ride lifecycle management
- **Driver Availability Management**: Flexible availability controls

## Smart Contract Functions

### User Registration
- `register-rider(name)` - Register as a rider
- `register-driver(name, vehicle-type, license-plate)` - Register as a driver

### Ride Management
- `request-ride(pickup-location, destination, fare)` - Request a new ride
- `accept-ride(ride-id)` - Accept a ride request (driver)
- `start-ride(ride-id)` - Start the ride (driver)
- `complete-ride(ride-id)` - Complete ride and process payment
- `cancel-ride(ride-id)` - Cancel a ride

### Utility Functions
- `set-driver-availability(available)` - Update driver availability
- `get-ride(ride-id)` - Get ride details
- `get-rider(rider)` - Get rider information
- `get-driver(driver)` - Get driver information

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing

### Installation

1. Clone the repository
```bash
git clone https://github.com/your-username/rideflow.git
cd rideflow
```

2. Install dependencies
```bash
clarinet check
```

3. Run tests
```bash
clarinet test
```

### Usage

1. **Register as a rider or driver**
2. **Request a ride** by specifying pickup location, destination, and fare
3. **Accept rides** as a driver when available
4. **Track ride progress** through status updates
5. **Complete rides** and receive automatic payment processing

## Contract Architecture

The RideFlow contract consists of several key components:

- **User Management**: Separate registration and profile management for riders and drivers
- **Ride Lifecycle**: Complete ride state management from request to completion
- **Payment Processing**: Automated fare calculation and distribution
- **Rating System**: Reputation tracking for quality assurance

## Security Features

- **Access Control**: Function-level permissions for different user types
- **Status Validation**: Prevents invalid state transitions
- **Payment Security**: Automated and transparent payment processing
- **Data Integrity**: Immutable ride records on the blockchain

## Platform Economics

- **Platform Fee**: 5% of ride fare (configurable by contract owner)
- **Driver Payment**: 95% of ride fare automatically distributed
- **Transparent Pricing**: All fees visible on-chain

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request
