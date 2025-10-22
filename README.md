# RideFlow 🚗

A decentralized ride-sharing platform built on the Stacks blockchain using Clarity smart contracts with multi-institution support and dynamic surge pricing.

## Overview

RideFlow revolutionizes transportation by creating a trustless, decentralized ride-sharing ecosystem where riders and drivers can connect directly without intermediaries. Built on Bitcoin's security through Stacks, RideFlow ensures transparent, secure, and efficient ride management across multiple ride-sharing institutions with intelligent dynamic pricing.

## Features

- **Multi-Institution Support**: Enable cross-institutional operations and credit recognition
- **Dynamic Surge Pricing**: Automatic fare adjustment based on real-time demand and supply
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
- **Demand-Based Pricing**: Surge multipliers respond to market conditions

## Dynamic Pricing System

RideFlow implements a sophisticated surge pricing algorithm that automatically adjusts fares based on real-time supply and demand metrics within each institution.

### How Surge Pricing Works

1. **Demand Tracking**: System monitors active ride requests per institution
2. **Supply Monitoring**: Tracks available drivers in real-time
3. **Ratio Calculation**: Computes demand-to-supply ratio (active rides per available driver)
4. **Surge Application**: Applies multiplier when demand exceeds threshold
5. **Cap Protection**: Maximum 5.0x multiplier prevents excessive pricing

### Surge Multiplier Formula

```
Base Multiplier: 1.0x (no surge)
Demand Threshold: 3 rides per driver (default, configurable)
Step Multiplier: 0.25x per threshold unit (default, configurable)

If (Active Rides / Available Drivers) > Threshold:
    Surge = 1.0x + ((Ratio - Threshold) × Step Multiplier)
    Capped at 5.0x maximum
```

### Example Scenarios

**Low Demand (No Surge)**
- Active Rides: 10
- Available Drivers: 20
- Ratio: 0.5 rides/driver
- Surge Multiplier: **1.0x** (below threshold)
- Base Fare: 5,000 micro-STX → Final Fare: **5,000 micro-STX**

**Moderate Demand (Low Surge)**
- Active Rides: 40
- Available Drivers: 10
- Ratio: 4.0 rides/driver
- Surge Multiplier: **1.25x** (1 unit above threshold)
- Base Fare: 5,000 micro-STX → Final Fare: **6,250 micro-STX**

**High Demand (High Surge)**
- Active Rides: 100
- Available Drivers: 10
- Ratio: 10.0 rides/driver
- Surge Multiplier: **2.75x** (7 units above threshold)
- Base Fare: 5,000 micro-STX → Final Fare: **13,750 micro-STX**

**Peak Demand (Maximum Surge)**
- Active Rides: 200
- Available Drivers: 10
- Ratio: 20.0 rides/driver
- Calculated: 5.25x, Capped at **5.0x**
- Base Fare: 5,000 micro-STX → Final Fare: **25,000 micro-STX**

### Surge Pricing Benefits

- **Fair Market Pricing**: Automatic adjustment to real conditions
- **Driver Incentives**: Higher earnings during peak times encourage more drivers
- **Demand Management**: Higher prices naturally reduce demand during peaks
- **Transparency**: All surge calculations visible on-chain
- **Institution Independence**: Each institution has separate surge metrics
- **Predictability**: Clear formula prevents arbitrary pricing

## Smart Contract Functions

### Institution Management
- `register-institution(name, fee-percentage)` - Register a new ride-sharing institution
- `set-institution-status(institution-id, is-active)` - Enable/disable institution (owner only)
- `set-institution-fee(institution-id, new-fee)` - Update institution fee percentage (owner only)
- `get-institution(institution-id)` - Get institution details
- `get-institution-by-owner(owner)` - Get institution owned by principal
- `get-institution-metrics(institution-id)` - Get real-time demand/supply metrics

### User Registration
- `register-rider(name, preferred-institution)` - Register as a rider with optional preferred institution
- `register-driver(name, vehicle-type, license-plate, institution-id)` - Register as a driver with specific institution
- `set-preferred-institution(institution-id)` - Update rider's preferred institution

### Ride Management
- `request-ride(pickup-lat, pickup-lng, destination-lat, destination-lng, preferred-institution)` - Request a ride with GPS coordinates and institution preference (automatically applies surge pricing)
- `calculate-fare(pickup-lat, pickup-lng, destination-lat, destination-lng, institution-id)` - Calculate fare with current surge multiplier
- `accept-ride(ride-id)` - Accept a ride request (driver from same institution)
- `start-ride(ride-id)` - Start the ride (driver)
- `complete-ride(ride-id)` - Complete ride and process payment with surge-adjusted fare
- `cancel-ride(ride-id)` - Cancel a ride

### Surge Pricing Functions
- `get-surge-info(institution-id)` - Get current surge multiplier and metrics for institution
- `get-surge-parameters()` - Get global surge pricing configuration
- `update-surge-parameters(enabled, demand-threshold, step-multiplier)` - Update surge settings (admin only)

### Utility Functions
- `set-driver-availability(available)` - Update driver availability (affects surge calculation)
- `get-ride(ride-id)` - Get ride details including surge multiplier applied
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
3. **Check current surge pricing** before requesting rides
4. **Request a ride** by specifying pickup location, destination, and optional institution preference (surge automatically applied)
5. **Accept rides** as a driver when available (only from same institution)
6. **Track ride progress** through status updates
7. **Complete rides** and receive automatic payment processing with surge-adjusted fare and institution fee distribution

## Multi-Institution Architecture

The RideFlow contract supports multiple ride-sharing institutions operating within the same blockchain infrastructure with independent surge pricing per institution.

### Institution Features
- **Separate Identity**: Each institution has its own identity, branding, and fee structure
- **Independent Surge Pricing**: Each institution maintains separate demand/supply metrics
- **Cross-Platform Recognition**: Drivers and riders can be recognized across different institutions
- **Fee Distribution**: Automated distribution of fees between platform, institution, and driver
- **Institution Analytics**: Track performance metrics and surge patterns per institution
- **Flexible Preferences**: Riders can set preferred institutions or choose per-ride

### Benefits
- **Reduced Operational Costs**: Shared infrastructure reduces deployment and maintenance costs
- **Enhanced User Experience**: Riders can access multiple service providers through one interface
- **Competitive Pricing**: Multiple institutions compete within the same ecosystem with transparent surge
- **Credit Portability**: User ratings and history can be recognized across institutions
- **Regulatory Compliance**: Each institution can maintain separate compliance while sharing technology
- **Market Efficiency**: Surge pricing ensures optimal resource allocation

## Contract Architecture

The RideFlow contract consists of several key components:

- **Institution Management**: Registration and management of multiple ride-sharing companies
- **User Management**: Separate registration and profile management for riders and drivers
- **Surge Pricing Engine**: Real-time demand/supply tracking and fare adjustment
- **Cross-Institution Operations**: Seamless integration between different service providers
- **Ride Lifecycle**: Complete ride state management from request to completion
- **Payment Processing**: Automated fare calculation and distribution with surge and institution fees
- **Rating System**: Reputation tracking for quality assurance across institutions
- **Metrics Tracking**: Real-time monitoring of active rides and available drivers

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

### Institution Metrics Map (for Surge Pricing)
```clarity
{
    active-rides: uint,
    available-drivers: uint,
    last-updated: uint
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
    base-fare: uint,
    surge-multiplier: uint,
    final-fare: uint,
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

1. **requested** - Rider has requested a ride (surge calculated and locked in)
2. **accepted** - Driver has accepted the ride (from same institution)
3. **in-progress** - Ride is currently happening
4. **completed** - Ride finished successfully with surge-adjusted fee distribution
5. **cancelled** - Ride was cancelled by rider or driver

## Platform Economics

### Fare Calculation with Surge Pricing

**Base Fare Formula:**
```
Base Fare = 2,000 micro-STX + (Distance × 100 micro-STX/unit)
```

**Surge Application:**
```
Final Fare = Base Fare × Surge Multiplier
```

**Fee Distribution:**
```
Platform Fee = Final Fare × 5% (default, configurable)
Institution Fee = Final Fare × Institution % (up to 50%)
Driver Payment = Final Fare - Platform Fee - Institution Fee
```

### Pricing Examples

**Example 1: Short Ride, No Surge**
- Distance: 20 units
- Base Fare: 2,000 + (20 × 100) = 4,000 micro-STX
- Surge Multiplier: 1.0x
- Final Fare: 4,000 micro-STX
- Platform Fee (5%): 200 micro-STX
- Institution Fee (10%): 400 micro-STX
- Driver Payment: 3,400 micro-STX

**Example 2: Long Ride, Moderate Surge**
- Distance: 100 units
- Base Fare: 2,000 + (100 × 100) = 12,000 micro-STX
- Surge Multiplier: 1.5x
- Final Fare: 18,000 micro-STX
- Platform Fee (5%): 900 micro-STX
- Institution Fee (10%): 1,800 micro-STX
- Driver Payment: 15,300 micro-STX

**Example 3: Medium Ride, High Surge**
- Distance: 50 units
- Base Fare: 2,000 + (50 × 100) = 7,000 micro-STX
- Surge Multiplier: 3.0x (high demand)
- Final Fare: 21,000 micro-STX
- Platform Fee (5%): 1,050 micro-STX
- Institution Fee (10%): 2,100 micro-STX
- Driver Payment: 17,850 micro-STX

### Surge Pricing Configuration

**Default Parameters:**
- Surge Enabled: Yes
- Demand Threshold: 3 rides per available driver
- Step Multiplier: 0.25x per threshold unit exceeded
- Minimum Multiplier: 1.0x (no surge)
- Maximum Multiplier: 5.0x (protection cap)

**Admin Controls:**
Contract owner can adjust:
- Enable/disable surge pricing globally
- Modify demand threshold (1-20 rides per driver)
- Adjust step multiplier (0.01x - 1.0x per unit)

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
| u112 | err-invalid-surge-params | Invalid surge pricing parameters |

## Input Validation Rules

- **Names**: 1-50 characters
- **Institution Names**: 1-30 characters
- **Vehicle Types**: 1-20 characters
- **License Plates**: 1-10 characters
- **GPS Coordinates**: Valid latitude (-90 to 90) and longitude (-180 to 180)
- **Base Fare**: 2,000 micro-STX minimum
- **Maximum Platform Fee**: 100% (1000 basis points)
- **Maximum Institution Fee**: 50% (500 basis points)
- **Surge Multiplier Range**: 1.0x to 5.0x
- **Surge Threshold Range**: 1 to 20 rides per driver
- **Surge Step Range**: 0.01x to 1.0x

## Example Usage

### Check Current Surge Pricing
```clarity
(contract-call? .rideflow get-surge-info u1)
;; Returns: {institution-id: u1, active-rides: u40, available-drivers: u10, 
;;          surge-multiplier: u125, surge-enabled: true, demand-threshold: u3, ...}
```

### Calculate Fare with Current Surge
```clarity
(contract-call? .rideflow calculate-fare 40742000 -74005000 40758000 -73985000 u1)
;; Returns: {distance: u50, base-fare: u7000, surge-multiplier: u125, final-fare: u8750}
```

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

### Request a Ride (Surge Auto-Applied)
```clarity
(contract-call? .rideflow request-ride 40742000 -74005000 40758000 -73985000 (some u1))
;; Surge multiplier calculated and locked in at request time
```

### Accept a Ride (same institution only)
```clarity
(contract-call? .rideflow accept-ride u1)
```

### Complete a Ride with Surge-Adjusted Payment
```clarity
(contract-call? .rideflow complete-ride u1)
;; Payment distributed based on surge-adjusted final fare
```

### Update Surge Parameters (Admin Only)
```clarity
(contract-call? .rideflow update-surge-parameters true u4 u30)
;; Enable surge, threshold: 4 rides/driver, step: 0.30x per unit
```

### Update Institution Fee (Owner Only)
```clarity
(contract-call? .rideflow set-institution-fee u1 u150) ;; 15% fee
```

## Testing

The contract includes comprehensive input validation, surge pricing logic, and error handling. Test cases should cover:

- Institution registration and management
- Surge pricing calculation under various demand/supply scenarios
- Cross-institution user interactions with independent surge
- Fee calculation and distribution with surge multipliers
- User registration scenarios
- Ride lifecycle management with dynamic pricing
- Payment processing with surge-adjusted fares
- Metrics tracking for surge calculation
- Edge cases (zero drivers, extreme demand, surge caps)
- Admin surge parameter updates

### Sample Test Structure
```bash
clarinet console

# Test institution registration
>> (contract-call? .rideflow register-institution "TestRide" u100)

# Test driver registration (updates available driver count)
>> (contract-call? .rideflow register-driver "Test Driver" "SUV" "TEST1" u1)

# Check initial surge (should be 1.0x with no demand)
>> (contract-call? .rideflow get-surge-info u1)

# Test rider registration
>> (contract-call? .rideflow register-rider "Test Rider" (some u1))

# Calculate fare with current surge
>> (contract-call? .rideflow calculate-fare 40742000 -74005000 40758000 -73985000 u1)

# Test ride request (increases active rides, affects surge)
>> (contract-call? .rideflow request-ride 40742000 -74005000 40758000 -73985000 (some u1))

# Check updated surge after ride request
>> (contract-call? .rideflow get-surge-info u1)

# Test ride acceptance (decreases available drivers, affects surge)
>> (contract-call? .rideflow accept-ride u1)

# Test surge parameter updates (admin)
>> (contract-call? .rideflow update-surge-parameters true u5 u20)

# Test ride completion (resets metrics)
>> (contract-call? .rideflow complete-ride u1)
```

## Deployment

### Testnet Deployment
1. Configure Clarinet.toml for testnet
2. Deploy using Clarinet
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
1. Ensure thorough testing of surge pricing logic
2. Validate surge parameters for production use
3. Configure for mainnet
4. Deploy with sufficient STX for deployment costs

## Future Enhancements

### Core Features
- **Predictive Surge**: Machine learning for surge forecasting
- **Scheduled Rides**: Future ride booking with estimated surge
- **Multi-stop Rides**: Support for multiple destinations
- **Recurring Rides**: Scheduled ride functionality across institutions
- **Driver Groups**: Fleet management capabilities per institution

### Surge Pricing Enhancements
- **Time-Based Surge**: Additional multipliers for peak hours
- **Location-Based Surge**: Geographic demand hotspots
- **Event-Driven Surge**: Special event pricing integration
- **Surge Notifications**: Real-time alerts for drivers and riders
- **Historical Surge Data**: Analytics and trend visualization

### Multi-Institution Features
- **Inter-Institution Transfers**: Allow drivers to switch institutions
- **Cross-Institution Rides**: Enable drivers from one institution to serve another
- **Institution Partnerships**: Formal partnership agreements and revenue sharing
- **Unified Rating System**: Cross-institution reputation aggregation
- **Competitive Surge**: Cross-institution surge comparison tools

### Technical Enhancements
- **Integration APIs**: Third-party service integration per institution
- **Mobile App**: Institution-branded mobile applications with surge display
- **Enhanced GPS Tracking**: Real-time location updates during rides
- **Route Optimization**: AI-powered route suggestions per institution
- **Analytics Dashboard**: Institution-specific performance and surge metrics
- **Oracle Integration**: External data feeds for enhanced surge accuracy

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features, especially surge-related logic
- Update documentation for any changes
- Ensure security considerations are addressed
- Test multi-institution scenarios thoroughly
- Validate all input parameters and error conditions
- Test surge pricing under various demand/supply conditions
- Ensure surge calculations are accurate and capped appropriately

