# RideFlow 🚗

A decentralized ride-sharing platform built on the Stacks blockchain using Clarity smart contracts with multi-institution support.

## Overview

RideFlow revolutionizes transportation by creating a trustless, decentralized ride-sharing ecosystem where riders and drivers can connect directly without intermediaries. Built on Bitcoin's security through Stacks, RideFlow ensures transparent, secure, and efficient ride management across multiple ride-sharing institutions.

## Features

- **Multi-Institution Support**: Enable cross-institutional operations and credit recognition
- **Decentralized Ride Matching**: Direct connection between riders and drivers across institutions
- **Institution Management**: Separate ride-sharing companies/platforms within one ecosystem
- **Cross-Platform Operations**: Seamless integration between different service providers
- **Geo-Location Integration**: GPS coordinate validation and distance-based fare calculation
- **Transparent Pricing**: Fair fare calculation with configurable institution and platform fees
- **Rating System**: Built-in reputation system for quality assurance
- **Secure Payments**: Blockchain-based payment processing with automated fee distribution
- **Real-time Status Tracking**: Complete ride lifecycle management
- **Driver Availability Management**: Flexible availability controls
- **Institution Fee Management**: Customizable fee structures per institution

## Smart Contract Functions

### Institution Management
- `register-institution(name, fee-percentage)` - Register a new ride-sharing institution
- `set-institution-status(institution-id, is-active)` - Enable/disable institution (owner only)
- `set-institution-fee(institution-id, new-fee)` - Update institution fee percentage (owner only)
- `get-institution(institution-id)` - Get institution details
- `get-institution-by-owner(owner)` - Get institution owned by principal

### User Registration
- `register-rider(name, preferred-institution)` - Register as a rider with optional preferred institution
- `register-driver(name, vehicle-type, license-plate, institution-id)` - Register as a driver with specific institution
- `set-preferred-institution(institution-id)` - Update rider's preferred institution

### Ride Management
- `request-ride(pickup-lat, pickup-lng, destination-lat, destination-lng, preferred-institution)` - Request a ride with GPS coordinates and institution preference
- `calculate-fare(pickup-lat, pickup-lng, destination-lat, destination-lng)` - Calculate fare based on distance
- `accept-ride(ride-id)` - Accept a ride request (driver from same institution)
- `start-ride(ride-id)` - Start the ride (driver)
- `complete-ride(ride-id)` - Complete ride and process payment with institution fee distribution
- `cancel-ride(ride-id)` - Cancel a ride

### Utility Functions
- `set-driver-availability(available)` - Update driver availability
- `get-ride(ride-id)` - Get ride details
- `get-rider(rider)` - Get rider information
- `get-driver(driver)` - Get driver information
- `get-drivers-by-institution(institution-id)` - Get drivers filtered by institution

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

1. **Register an institution** (for ride-sharing companies)
2. **Register as a rider or driver** with institution preference/assignment
3. **Request a ride** by specifying pickup location, destination, and optional institution preference
4. **Accept rides** as a driver when available (only from same institution)
5. **Track ride progress** through status updates
6. **Complete rides** and receive automatic payment processing with institution fee distribution

## Multi-Institution Architecture

The RideFlow contract now supports multiple ride-sharing institutions operating within the same blockchain infrastructure:

### Institution Features
- **Separate Identity**: Each institution has its own identity, branding, and fee structure
- **Cross-Platform Recognition**: Drivers and riders can be recognized across different institutions
- **Fee Distribution**: Automated distribution of fees between platform, institution, and driver
- **Institution Analytics**: Track performance metrics per institution
- **Flexible Preferences**: Riders can set preferred institutions or choose per-ride

### Benefits
- **Reduced Operational Costs**: Shared infrastructure reduces deployment and maintenance costs
- **Enhanced User Experience**: Riders can access multiple service providers through one interface
- **Competitive Pricing**: Multiple institutions compete within the same ecosystem
- **Credit Portability**: User ratings and history can be recognized across institutions
- **Regulatory Compliance**: Each institution can maintain separate compliance while sharing technology

## Contract Architecture

The RideFlow contract consists of several key components:

- **Institution Management**: Registration and management of multiple ride-sharing companies
- **User Management**: Separate registration and profile management for riders and drivers
- **Cross-Institution Operations**: Seamless integration between different service providers
- **Ride Lifecycle**: Complete ride state management from request to completion
- **Payment Processing**: Automated fare calculation and distribution with institution fees
- **Rating System**: Reputation tracking for quality assurance across institutions

## Data Structures

### Institutions Map
```clarity
{
    name: (string-ascii 30),
    owner: principal,
    fee-percentage: uint,
    is-active: bool,
    total-drivers: uint,
    total-rides: uint,
    created-at: uint
}
```

### Riders Map
```clarity
{
    name: (string-ascii 50),
    rating: uint,
    total-rides: uint,
    is-active: bool,
    preferred-institution: (optional uint)
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
    is-active: bool,
    institution-id: uint
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
    completed-at: (optional uint),
    institution-id: uint
}
```

### Ride Payments Map
```clarity
{
    rider: principal,
    driver: principal,
    fare: uint,
    platform-fee: uint,
    institution-fee: uint,
    driver-payment: uint,
    institution-id: uint,
    is-paid: bool
}
```

## Ride Status Flow

1. **requested** - Rider has requested a ride
2. **accepted** - Driver has accepted the ride (from same institution)
3. **in-progress** - Ride is currently happening
4. **completed** - Ride finished successfully with fee distribution
5. **cancelled** - Ride was cancelled by rider or driver

## Multi-Institution Security Features

- **Institution Validation**: Ensures only active institutions can operate
- **Cross-Institution Access Control**: Drivers can only accept rides from their institution
- **Fee Validation**: Prevents excessive institution fees (max 50%)
- **Owner Authorization**: Only institution owners can modify their institution settings
- **Status Management**: Institutions can be activated/deactivated as needed
- **Payment Segregation**: Separate fee calculation and distribution per institution

## Platform Economics

- **Distance-Based Pricing**: Fare calculated using GPS coordinates and distance
- **Base Fare**: 2000 micro-STX minimum + distance multiplier
- **Platform Fee**: 5% of ride fare (configurable by contract owner)
- **Institution Fee**: Up to 50% of ride fare (configurable per institution)
- **Driver Payment**: Remaining fare after platform and institution fees
- **Transparent Pricing**: All fees and distance calculations visible on-chain

### Fee Distribution Example
For a 10,000 micro-STX ride:
- Platform Fee (5%): 500 micro-STX
- Institution Fee (10%): 1,000 micro-STX
- Driver Payment: 8,500 micro-STX

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
| u108 | err-invalid-coordinates | Invalid GPS coordinates |
| u109 | err-institution-not-active | Institution is not active |
| u110 | err-institution-exists | Institution already exists for owner |
| u111 | err-invalid-institution-fee | Invalid institution fee (>50%) |

## Input Validation Rules

- **Names**: 1-50 characters
- **Institution Names**: 1-30 characters
- **Vehicle Types**: 1-20 characters
- **License Plates**: 1-10 characters
- **GPS Coordinates**: Valid latitude (-90 to 90) and longitude (-180 to 180)
- **Base Fare**: 2000 micro-STX minimum
- **Maximum Platform Fee**: 100% (1000 basis points)
- **Maximum Institution Fee**: 50% (500 basis points)

## Example Usage

### Register an Institution
```clarity
(contract-call? .rideflow register-institution "UberClone" u100) ;; 10% fee
```

### Register as a Driver with Institution
```clarity
(contract-call? .rideflow register-driver "John Smith" "Sedan" "ABC123" u1)
```

### Register as Rider with Preferred Institution
```clarity
(contract-call? .rideflow register-rider "Jane Doe" (some u1))
```

### Calculate Fare Based on Distance
```clarity
(contract-call? .rideflow calculate-fare 40742000 -74005000 40758000 -73985000)
```

### Request a Ride with Institution Preference
```clarity
(contract-call? .rideflow request-ride 40742000 -74005000 40758000 -73985000 (some u1))
```

### Accept a Ride (same institution only)
```clarity
(contract-call? .rideflow accept-ride u1)
```

### Complete a Ride with Institution Fee Distribution
```clarity
(contract-call? .rideflow complete-ride u1)
```

### Update Institution Fee (owner only)
```clarity
(contract-call? .rideflow set-institution-fee u1 u150) ;; 15% fee
```

## Testing

The contract includes comprehensive input validation and error handling. Test cases should cover:

- Institution registration and management
- Cross-institution user interactions
- Fee calculation and distribution
- User registration scenarios
- Ride lifecycle management
- Payment processing with institution fees
- Error conditions and edge cases

### Sample Test Structure
```bash
# Test institution registration
clarinet console
>> (contract-call? .rideflow register-institution "TestRide" u100)

# Test driver registration with institution
>> (contract-call? .rideflow register-driver "Test Driver" "SUV" "TEST1" u1)

# Test rider registration with preferred institution
>> (contract-call? .rideflow register-rider "Test Rider" (some u1))

# Test GPS coordinate validation
>> (contract-call? .rideflow calculate-fare 40742000 -74005000 40758000 -73985000)

# Test ride request with institution preference
>> (contract-call? .rideflow request-ride 40742000 -74005000 40758000 -73985000 (some u1))

# Test ride acceptance (as different principal from same institution)
>> (contract-call? .rideflow accept-ride u1)

# Test institution management
>> (contract-call? .rideflow set-institution-status u1 false)
```

## Deployment

### Testnet Deployment
1. Configure Clarinet.toml for testnet
2. Deploy using Clarinet
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
1. Ensure thorough testing across institutions
2. Configure for mainnet
3. Deploy with sufficient STX for deployment costs

## Future Enhancements

### Core Features
- **Dynamic Pricing**: Surge pricing based on demand per institution
- **Multi-stop Rides**: Support for multiple destinations
- **Recurring Rides**: Scheduled ride functionality across institutions
- **Driver Groups**: Fleet management capabilities per institution

### Multi-Institution Features
- **Inter-Institution Transfers**: Allow drivers to switch institutions
- **Cross-Institution Rides**: Enable drivers from one institution to serve another
- **Institution Partnerships**: Formal partnership agreements and revenue sharing
- **Unified Rating System**: Cross-institution reputation aggregation

### Technical Enhancements
- **Integration APIs**: Third-party service integration per institution
- **Mobile App**: Institution-branded mobile applications
- **Enhanced GPS Tracking**: Real-time location updates during rides
- **Route Optimization**: AI-powered route suggestions per institution
- **Analytics Dashboard**: Institution-specific performance metrics

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
- Test multi-institution scenarios thoroughly
- Validate all input parameters and error conditions

## Disclaimer

This is experimental software. Use at your own risk. The smart contract has not been audited and may contain vulnerabilities. Multi-institution support adds complexity that requires careful testing and validation.