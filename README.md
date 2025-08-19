# RideFlow 🚗

A decentralized ride-sharing platform built on the Stacks blockchain using Clarity smart contracts.

## Overview

RideFlow revolutionizes transportation by creating a trustless, decentralized ride-sharing ecosystem where riders and drivers can connect directly without intermediaries. Built on Bitcoin's security through Stacks, RideFlow ensures transparent, secure, and efficient ride management.

## Features

- **Decentralized Ride Matching**: Direct connection between riders and drivers
- **Geo-Location Integration**: GPS coordinate validation and distance-based fare calculation
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
- `request-ride(pickup-lat, pickup-lng, destination-lat, destination-lng)` - Request a new ride with GPS coordinates
- `calculate-fare(pickup-lat, pickup-lng, destination-lat, destination-lng)` - Calculate fare based on distance
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

## Data Structures

### Riders Map
```clarity
{
    name: (string-ascii 50),
    rating: uint,
    total-rides: uint,
    is-active: bool
}
```

### Drivers Map
```clarity
{
    name: (string-ascii 50),
    vehicle-type: (string-ascii 20),
    license-plate: (string-ascii 10),
    rating: uint,
    total-rides: uint,
    is-available: bool,
    is-active: bool
}
```

### Rides Map
```clarity
{
    rider: principal,
    driver: (optional principal),
    pickup-lat: int,
    pickup-lng: int,
    destination-lat: int,
    destination-lng: int,
    distance: uint,
    fare: uint,
    status: (string-ascii 20),
    created-at: uint,
    completed-at: (optional uint)
}
```

## Ride Status Flow

1. **requested** - Rider has requested a ride
2. **accepted** - Driver has accepted the ride
3. **in-progress** - Ride is currently happening
4. **completed** - Ride finished successfully
5. **cancelled** - Ride was cancelled by rider or driver

## Security Features

- **Access Control**: Function-level permissions for different user types
- **Status Validation**: Prevents invalid state transitions
- **Input Validation**: Comprehensive validation for all user inputs
- **Payment Security**: Automated and transparent payment processing
- **Data Integrity**: Immutable ride records on the blockchain

## Platform Economics

- **Distance-Based Pricing**: Fare calculated using GPS coordinates and distance
- **Base Fare**: 2000 micro-STX minimum + distance multiplier
- **Platform Fee**: 5% of ride fare (configurable by contract owner)
- **Driver Payment**: 95% of ride fare automatically distributed
- **Transparent Pricing**: All fees and distance calculations visible on-chain

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | err-owner-only | Only contract owner can perform this action |
| u101 | err-not-found | Requested entity not found |
| u102 | err-already-exists | Entity already exists |
| u103 | err-invalid-status | Invalid status for operation |
| u104 | err-insufficient-payment | Payment amount insufficient |
| u105 | err-unauthorized | User not authorized for action |
| u106 | err-invalid-input | Invalid input parameters |
| u107 | err-invalid-fee | Invalid fee amount |

## Input Validation Rules

- **Names**: 1-50 characters
- **Vehicle Types**: 1-20 characters
- **License Plates**: 1-10 characters
- **GPS Coordinates**: Valid latitude (-90 to 90) and longitude (-180 to 180)
- **Base Fare**: 2000 micro-STX minimum
- **Maximum Platform Fee**: 100% (1000 basis points)

## Example Usage

### Register as a Driver
```clarity
(contract-call? .rideflow register-driver "John Smith" "Sedan" "ABC123")
```

### Calculate Fare Based on Distance
```clarity
(contract-call? .rideflow calculate-fare 40742000 -74005000 40758000 -73985000)
```

### Request a Ride with GPS Coordinates
```clarity
(contract-call? .rideflow request-ride 40742000 -74005000 40758000 -73985000)
```

### Accept a Ride
```clarity
(contract-call? .rideflow accept-ride u1)
```

### Complete a Ride
```clarity
(contract-call? .rideflow complete-ride u1)
```

## Testing

The contract includes comprehensive input validation and error handling. Test cases should cover:

- User registration scenarios
- Ride lifecycle management
- Payment processing
- Error conditions
- Edge cases

### Sample Test Structure
```bash
# Test user registration
clarinet console
>> (contract-call? .rideflow register-rider "Test Rider")

# Test GPS coordinate validation
>> (contract-call? .rideflow calculate-fare 40742000 -74005000 40758000 -73985000)

# Test ride request with coordinates
>> (contract-call? .rideflow request-ride 40742000 -74005000 40758000 -73985000)

# Test ride acceptance (as different principal)
>> (contract-call? .rideflow accept-ride u1)
```

## Deployment

### Testnet Deployment
1. Configure Clarinet.toml for testnet
2. Deploy using Clarinet
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
1. Ensure thorough testing
2. Configure for mainnet
3. Deploy with sufficient STX for deployment costs

## Future Enhancements

- **Dynamic Pricing**: Surge pricing based on demand
- **Multi-stop Rides**: Support for multiple destinations
- **Recurring Rides**: Scheduled ride functionality
- **Driver Groups**: Fleet management capabilities
- **Integration APIs**: Third-party service integration
- **Mobile App**: Native mobile applications
- **Enhanced GPS Tracking**: Real-time location updates during rides
- **Route Optimization**: AI-powered route suggestions

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for any changes
- Ensure security considerations are addressed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This is experimental software. Use at your own risk. The smart contract has not been audited and may contain vulnerabilities.

