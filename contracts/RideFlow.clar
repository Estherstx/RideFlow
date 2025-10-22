;; RideFlow - Decentralized Ride-Sharing Platform
;; A smart contract for managing ride requests, driver matching, and payments
;; Updated with GPS coordinate validation, simplified distance-based fare calculation,
;; multi-institution support, and dynamic surge pricing based on demand/supply metrics

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-insufficient-payment (err u104))
(define-constant err-unauthorized (err u105))
(define-constant err-invalid-input (err u106))
(define-constant err-invalid-fee (err u107))
(define-constant err-invalid-coordinates (err u108))
(define-constant err-institution-not-active (err u109))
(define-constant err-institution-exists (err u110))
(define-constant err-invalid-institution-fee (err u111))
(define-constant err-invalid-surge-params (err u112))

;; Input validation constants
(define-constant max-string-length u50)
(define-constant max-vehicle-length u20)
(define-constant max-plate-length u10)
(define-constant max-institution-name-length u30)
(define-constant base-fare u2000) ;; Base fare in micro-STX
(define-constant max-fee u1000) ;; Maximum platform fee 100%
(define-constant max-institution-fee u500) ;; Maximum institution fee 50%

;; GPS coordinate constants (in micro-degrees: lat/lng * 1,000,000)
(define-constant min-latitude -90000000)
(define-constant max-latitude 90000000)
(define-constant min-longitude -180000000)
(define-constant max-longitude 180000000)

;; Distance and fare calculation constants
(define-constant fare-per-unit u100) ;; 100 micro-STX per distance unit

;; Surge pricing constants
(define-constant min-surge-multiplier u100) ;; 1.0x (in basis points: 100 = 1.0x)
(define-constant max-surge-multiplier u500) ;; 5.0x maximum surge
(define-constant surge-base u100) ;; Base multiplier (1.0x)
(define-constant default-surge-threshold u3) ;; Demand/supply ratio threshold

;; Data Variables
(define-data-var ride-counter uint u0)
(define-data-var platform-fee uint u50) ;; 5% platform fee (in basis points)
(define-data-var institution-counter uint u0)

;; Surge pricing parameters
(define-data-var surge-enabled bool true)
(define-data-var surge-demand-threshold uint u3) ;; Rides per available driver threshold
(define-data-var surge-step-multiplier uint u25) ;; Additional 0.25x per threshold unit

;; Data Maps
(define-map institutions uint {
    name: (string-ascii 30),
    owner: principal,
    fee-percentage: uint,
    is-active: bool,
    total-drivers: uint,
    total-rides: uint,
    created-at: uint
})

(define-map institution-by-owner principal uint)

;; Track active rides and available drivers per institution for surge pricing
(define-map institution-metrics uint {
    active-rides: uint,
    available-drivers: uint,
    last-updated: uint
})

(define-map riders principal {
    name: (string-ascii 50),
    rating: uint,
    total-rides: uint,
    is-active: bool,
    preferred-institution: (optional uint)
})

(define-map drivers principal {
    name: (string-ascii 50),
    vehicle-type: (string-ascii 20),
    license-plate: (string-ascii 10),
    rating: uint,
    total-rides: uint,
    is-available: bool,
    is-active: bool,
    institution-id: uint
})

(define-map rides uint {
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
    status: (string-ascii 20), ;; "requested", "accepted", "in-progress", "completed", "cancelled"
    created-at: uint,
    completed-at: (optional uint),
    institution-id: uint
})

(define-map ride-payments uint {
    rider: principal,
    driver: principal,
    fare: uint,
    platform-fee: uint,
    institution-fee: uint,
    driver-payment: uint,
    institution-id: uint,
    is-paid: bool
})

;; Input validation helpers
(define-private (is-valid-string (str (string-ascii 50)))
    (and (> (len str) u0) (<= (len str) max-string-length))
)

(define-private (is-valid-institution-name (name (string-ascii 30)))
    (and (> (len name) u0) (<= (len name) max-institution-name-length))
)

(define-private (is-valid-vehicle-type (vehicle (string-ascii 20)))
    (and (> (len vehicle) u0) (<= (len vehicle) max-vehicle-length))
)

(define-private (is-valid-plate (plate (string-ascii 10)))
    (and (> (len plate) u0) (<= (len plate) max-plate-length))
)

(define-private (is-valid-fee (fee uint))
    (<= fee max-fee)
)

(define-private (is-valid-institution-fee (fee uint))
    (<= fee max-institution-fee)
)

;; GPS coordinate validation
(define-private (is-valid-latitude (lat int))
    (and (>= lat min-latitude) (<= lat max-latitude))
)

(define-private (is-valid-longitude (lng int))
    (and (>= lng min-longitude) (<= lng max-longitude))
)

(define-private (is-valid-coordinates (lat int) (lng int))
    (and (is-valid-latitude lat) (is-valid-longitude lng))
)

;; Surge pricing validation
(define-private (is-valid-surge-multiplier (multiplier uint))
    (and (>= multiplier min-surge-multiplier) (<= multiplier max-surge-multiplier))
)

(define-private (is-valid-surge-threshold (threshold uint))
    (and (> threshold u0) (<= threshold u20))
)

(define-private (is-valid-surge-step (step uint))
    (and (> step u0) (<= step u100))
)

;; Institution validation
(define-private (is-institution-active (institution-id uint))
    (match (map-get? institutions institution-id)
        institution-data (get is-active institution-data)
        false
    )
)

(define-private (validate-institution-exists-and-active (institution-id uint))
    (let ((institution-data (map-get? institutions institution-id)))
        (and 
            (is-some institution-data)
            (get is-active (unwrap-panic institution-data))
        )
    )
)

(define-private (validate-optional-institution (institution (optional uint)))
    (match institution
        institution-id 
            (and 
                (> institution-id u0) 
                (validate-institution-exists-and-active institution-id)
            )
        true ;; None is valid
    )
)

;; Simplified distance calculation using Manhattan distance
(define-private (calculate-simple-distance (lat1 int) (lng1 int) (lat2 int) (lng2 int))
    (let (
        (lat-diff (if (> lat1 lat2) (to-uint (- lat1 lat2)) (to-uint (- lat2 lat1))))
        (lng-diff (if (> lng1 lng2) (to-uint (- lng1 lng2)) (to-uint (- lng2 lng1))))
        (manhattan-distance (+ lat-diff lng-diff))
        (scaled-distance (/ manhattan-distance u10000))
    )
        (if (> scaled-distance u0) scaled-distance u1)
    )
)

;; Calculate surge multiplier based on demand and supply
(define-private (calculate-surge-multiplier (institution-id uint))
    (let (
        (metrics (default-to 
            {active-rides: u0, available-drivers: u0, last-updated: u0}
            (map-get? institution-metrics institution-id)))
        (active-rides (get active-rides metrics))
        (available-drivers (get available-drivers metrics))
        (threshold (var-get surge-demand-threshold))
        (step-multiplier (var-get surge-step-multiplier))
    )
        (if (and (var-get surge-enabled) (> available-drivers u0))
            (let (
                ;; Calculate demand ratio (rides per driver)
                (demand-ratio (/ active-rides available-drivers))
                ;; Calculate how many threshold units we've exceeded
                (threshold-units (if (> demand-ratio threshold)
                    (- demand-ratio threshold)
                    u0))
                ;; Calculate surge: base + (threshold-units * step-multiplier)
                (calculated-surge (+ surge-base (* threshold-units step-multiplier)))
                ;; Cap at maximum surge multiplier
                (capped-surge (if (> calculated-surge max-surge-multiplier)
                    max-surge-multiplier
                    calculated-surge))
            )
                ;; Ensure minimum surge of 1.0x
                (if (< capped-surge min-surge-multiplier)
                    min-surge-multiplier
                    capped-surge)
            )
            surge-base ;; Default to 1.0x if surge disabled or no drivers
        )
    )
)

;; Calculate base fare based on distance
(define-private (calculate-base-fare (distance uint))
    (+ base-fare (* distance fare-per-unit))
)

;; Calculate final fare with surge pricing
(define-private (calculate-fare-with-surge (distance uint) (institution-id uint))
    (let (
        (calculated-base-fare (calculate-base-fare distance))
        (surge-multiplier (calculate-surge-multiplier institution-id))
        ;; Apply surge: (base-fare * surge-multiplier) / 100
        (final-fare (/ (* calculated-base-fare surge-multiplier) u100))
    )
        {
            base-fare: calculated-base-fare,
            surge-multiplier: surge-multiplier,
            final-fare: final-fare
        }
    )
)

;; Update institution metrics for surge pricing
(define-private (update-institution-metrics (institution-id uint) (active-rides-delta int) (available-drivers-delta int))
    (let (
        (current-metrics (default-to
            {active-rides: u0, available-drivers: u0, last-updated: u0}
            (map-get? institution-metrics institution-id)))
        (current-active (get active-rides current-metrics))
        (current-available (get available-drivers current-metrics))
        (new-active (if (>= active-rides-delta 0)
            (+ current-active (to-uint active-rides-delta))
            (if (>= current-active (to-uint (- 0 active-rides-delta)))
                (- current-active (to-uint (- 0 active-rides-delta)))
                u0)))
        (new-available (if (>= available-drivers-delta 0)
            (+ current-available (to-uint available-drivers-delta))
            (if (>= current-available (to-uint (- 0 available-drivers-delta)))
                (- current-available (to-uint (- 0 available-drivers-delta)))
                u0)))
    )
        (map-set institution-metrics institution-id {
            active-rides: new-active,
            available-drivers: new-available,
            last-updated: stacks-block-height
        })
        true
    )
)

;; Public Functions

;; Register a new institution
(define-public (register-institution (name (string-ascii 30)) (fee-percentage uint))
    (let (
        (institution-id (+ (var-get institution-counter) u1))
        (owner tx-sender)
    )
        (asserts! (is-valid-institution-name name) err-invalid-input)
        (asserts! (is-valid-institution-fee fee-percentage) err-invalid-institution-fee)
        (asserts! (is-none (map-get? institution-by-owner owner)) err-institution-exists)
        
        (var-set institution-counter institution-id)
        (map-set institutions institution-id {
            name: name,
            owner: owner,
            fee-percentage: fee-percentage,
            is-active: true,
            total-drivers: u0,
            total-rides: u0,
            created-at: stacks-block-height
        })
        (map-set institution-by-owner owner institution-id)
        
        ;; Initialize metrics for surge pricing
        (map-set institution-metrics institution-id {
            active-rides: u0,
            available-drivers: u0,
            last-updated: stacks-block-height
        })
        
        (ok institution-id)
    )
)

;; Update institution status (owner only)
(define-public (set-institution-status (institution-id uint) (is-active bool))
    (let (
        (institution-data (unwrap! (map-get? institutions institution-id) err-not-found))
        (caller tx-sender)
    )
        (asserts! (is-eq caller (get owner institution-data)) err-unauthorized)
        (map-set institutions institution-id (merge institution-data {
            is-active: is-active
        }))
        (ok true)
    )
)

;; Update institution fee (owner only)
(define-public (set-institution-fee (institution-id uint) (new-fee uint))
    (let (
        (institution-data (unwrap! (map-get? institutions institution-id) err-not-found))
        (caller tx-sender)
    )
        (asserts! (is-eq caller (get owner institution-data)) err-unauthorized)
        (asserts! (is-valid-institution-fee new-fee) err-invalid-institution-fee)
        (map-set institutions institution-id (merge institution-data {
            fee-percentage: new-fee
        }))
        (ok true)
    )
)

;; Register as a rider with optional preferred institution
(define-public (register-rider (name (string-ascii 50)) (preferred-institution (optional uint)))
    (let ((rider tx-sender))
        (asserts! (is-valid-string name) err-invalid-input)
        (asserts! (validate-optional-institution preferred-institution) err-institution-not-active)
        
        (map-set riders rider {
            name: name,
            rating: u5,
            total-rides: u0,
            is-active: true,
            preferred-institution: preferred-institution
        })
        (ok true)
    )
)

;; Register as a driver with institution
(define-public (register-driver (name (string-ascii 50)) (vehicle-type (string-ascii 20)) (license-plate (string-ascii 10)) (institution-id uint))
    (let (
        (driver tx-sender)
        (institution-data (unwrap! (map-get? institutions institution-id) err-not-found))
    )
        (asserts! (is-valid-string name) err-invalid-input)
        (asserts! (is-valid-vehicle-type vehicle-type) err-invalid-input)
        (asserts! (is-valid-plate license-plate) err-invalid-input)
        (asserts! (> institution-id u0) err-invalid-input)
        (asserts! (get is-active institution-data) err-institution-not-active)
        
        (map-set drivers driver {
            name: name,
            vehicle-type: vehicle-type,
            license-plate: license-plate,
            rating: u5,
            total-rides: u0,
            is-available: true,
            is-active: true,
            institution-id: institution-id
        })
        
        ;; Update institution driver count and metrics
        (map-set institutions institution-id (merge institution-data {
            total-drivers: (+ (get total-drivers institution-data) u1)
        }))
        
        (update-institution-metrics institution-id 0 1)
        
        (ok true)
    )
)

;; Calculate fare for given coordinates with surge pricing
(define-read-only (calculate-fare (pickup-lat int) (pickup-lng int) (destination-lat int) (destination-lng int) (institution-id uint))
    (begin
        (asserts! (is-valid-coordinates pickup-lat pickup-lng) err-invalid-coordinates)
        (asserts! (is-valid-coordinates destination-lat destination-lng) err-invalid-coordinates)
        (asserts! (> institution-id u0) err-invalid-input)
        (let (
            (distance (calculate-simple-distance pickup-lat pickup-lng destination-lat destination-lng))
            (fare-info (calculate-fare-with-surge distance institution-id))
        )
            (ok {
                distance: distance,
                base-fare: (get base-fare fare-info),
                surge-multiplier: (get surge-multiplier fare-info),
                final-fare: (get final-fare fare-info)
            })
        )
    )
)

;; Request a ride with GPS coordinates and optional institution preference
(define-public (request-ride (pickup-lat int) (pickup-lng int) (destination-lat int) (destination-lng int) (preferred-institution (optional uint)))
    (let (
        (ride-id (+ (var-get ride-counter) u1))
        (rider tx-sender)
        (rider-data (unwrap! (map-get? riders rider) err-not-found))
        (distance (calculate-simple-distance pickup-lat pickup-lng destination-lat destination-lng))
    )
        (asserts! (is-valid-coordinates pickup-lat pickup-lng) err-invalid-coordinates)
        (asserts! (is-valid-coordinates destination-lat destination-lng) err-invalid-coordinates)
        (asserts! (validate-optional-institution preferred-institution) err-institution-not-active)
        
        (let ((final-institution 
            (match preferred-institution
                pref-id pref-id
                (match (get preferred-institution rider-data)
                    rider-pref (begin
                        (asserts! (validate-institution-exists-and-active rider-pref) err-institution-not-active)
                        rider-pref
                    )
                    u1
                )
            )))
            
            (asserts! (validate-institution-exists-and-active final-institution) err-institution-not-active)
            
            (let ((fare-info (calculate-fare-with-surge distance final-institution)))
                (var-set ride-counter ride-id)
                (map-set rides ride-id {
                    rider: rider,
                    driver: none,
                    pickup-lat: pickup-lat,
                    pickup-lng: pickup-lng,
                    destination-lat: destination-lat,
                    destination-lng: destination-lng,
                    distance: distance,
                    base-fare: (get base-fare fare-info),
                    surge-multiplier: (get surge-multiplier fare-info),
                    final-fare: (get final-fare fare-info),
                    status: "requested",
                    created-at: stacks-block-height,
                    completed-at: none,
                    institution-id: final-institution
                })
                
                ;; Update metrics: increment active rides
                (update-institution-metrics final-institution 1 0)
                
                (ok ride-id)
            )
        )
    )
)

;; Accept a ride (driver from same institution)
(define-public (accept-ride (ride-id uint))
    (let (
        (driver tx-sender)
        (ride (unwrap! (map-get? rides ride-id) err-not-found))
        (driver-info (unwrap! (map-get? drivers driver) err-not-found))
        (ride-institution-id (get institution-id ride))
        (driver-institution-id (get institution-id driver-info))
    )
        (asserts! (is-eq (get status ride) "requested") err-invalid-status)
        (asserts! (get is-available driver-info) err-unauthorized)
        (asserts! (is-eq driver-institution-id ride-institution-id) err-unauthorized)
        (asserts! (validate-institution-exists-and-active ride-institution-id) err-institution-not-active)
        
        (map-set rides ride-id (merge ride {
            driver: (some driver),
            status: "accepted"
        }))
        (map-set drivers driver (merge driver-info {
            is-available: false
        }))
        
        ;; Update metrics: decrement available drivers
        (update-institution-metrics ride-institution-id 0 -1)
        
        (ok true)
    )
)

;; Start ride (driver)
(define-public (start-ride (ride-id uint))
    (let (
        (driver tx-sender)
        (ride (unwrap! (map-get? rides ride-id) err-not-found))
    )
        (asserts! (is-eq (some driver) (get driver ride)) err-unauthorized)
        (asserts! (is-eq (get status ride) "accepted") err-invalid-status)
        (map-set rides ride-id (merge ride {
            status: "in-progress"
        }))
        (ok true)
    )
)

;; Complete ride and process payment with institution fee distribution
(define-public (complete-ride (ride-id uint))
    (let (
        (driver tx-sender)
        (ride (unwrap! (map-get? rides ride-id) err-not-found))
        (driver-info (unwrap! (map-get? drivers driver) err-not-found))
        (rider-info (unwrap! (map-get? riders (get rider ride)) err-not-found))
        (ride-institution-id (get institution-id ride))
        (institution-data (unwrap! (map-get? institutions ride-institution-id) err-not-found))
        (fare (get final-fare ride))
        (calculated-platform-fee (/ (* fare (var-get platform-fee)) u1000))
        (calculated-institution-fee (/ (* fare (get fee-percentage institution-data)) u1000))
        (driver-payment (- fare (+ calculated-platform-fee calculated-institution-fee)))
    )
        (asserts! (is-eq (some driver) (get driver ride)) err-unauthorized)
        (asserts! (is-eq (get status ride) "in-progress") err-invalid-status)
        (asserts! (get is-active institution-data) err-institution-not-active)
        
        ;; Update ride status
        (map-set rides ride-id (merge ride {
            status: "completed",
            completed-at: (some stacks-block-height)
        }))
        
        ;; Record payment
        (map-set ride-payments ride-id {
            rider: (get rider ride),
            driver: driver,
            fare: fare,
            platform-fee: calculated-platform-fee,
            institution-fee: calculated-institution-fee,
            driver-payment: driver-payment,
            institution-id: ride-institution-id,
            is-paid: true
        })
        
        ;; Update driver availability and stats
        (map-set drivers driver (merge driver-info {
            is-available: true,
            total-rides: (+ (get total-rides driver-info) u1)
        }))
        
        ;; Update rider stats
        (map-set riders (get rider ride) (merge rider-info {
            total-rides: (+ (get total-rides rider-info) u1)
        }))
        
        ;; Update institution stats
        (map-set institutions ride-institution-id (merge institution-data {
            total-rides: (+ (get total-rides institution-data) u1)
        }))
        
        ;; Update metrics: decrement active rides, increment available drivers
        (update-institution-metrics ride-institution-id -1 1)
        
        (ok true)
    )
)

;; Cancel ride
(define-public (cancel-ride (ride-id uint))
    (let (
        (ride (unwrap! (map-get? rides ride-id) err-not-found))
        (caller tx-sender)
        (ride-institution-id (get institution-id ride))
    )
        (asserts! (or (is-eq caller (get rider ride)) 
                     (is-eq (some caller) (get driver ride))) err-unauthorized)
        (asserts! (not (is-eq (get status ride) "completed")) err-invalid-status)
        
        ;; Update ride status
        (map-set rides ride-id (merge ride {
            status: "cancelled"
        }))
        
        ;; Update metrics: decrement active rides
        (update-institution-metrics ride-institution-id -1 0)
        
        ;; If driver was assigned, make them available again and update metrics
        (match (get driver ride)
            driver-principal (let ((driver-info (unwrap! (map-get? drivers driver-principal) err-not-found)))
                (map-set drivers driver-principal (merge driver-info {
                    is-available: true
                }))
                (update-institution-metrics ride-institution-id 0 1)
                (ok true)
            )
            (ok true)
        )
    )
)

;; Update driver availability
(define-public (set-driver-availability (available bool))
    (let (
        (driver tx-sender)
        (driver-info (unwrap! (map-get? drivers driver) err-not-found))
        (institution-id (get institution-id driver-info))
        (was-available (get is-available driver-info))
    )
        (map-set drivers driver (merge driver-info {
            is-available: available
        }))
        
        ;; Update metrics based on availability change
        (if (and (not was-available) available)
            (update-institution-metrics institution-id 0 1)
            (if (and was-available (not available))
                (update-institution-metrics institution-id 0 -1)
                true
            )
        )
        
        (ok true)
    )
)

;; Update rider preferred institution
(define-public (set-preferred-institution (institution-id (optional uint)))
    (let (
        (rider tx-sender)
        (rider-info (unwrap! (map-get? riders rider) err-not-found))
    )
        (asserts! (validate-optional-institution institution-id) err-institution-not-active)
        
        (map-set riders rider (merge rider-info {
            preferred-institution: institution-id
        }))
        (ok true)
    )
)

;; Admin function to update surge pricing parameters
(define-public (update-surge-parameters (enabled bool) (demand-threshold uint) (step-multiplier uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-valid-surge-threshold demand-threshold) err-invalid-surge-params)
        (asserts! (is-valid-surge-step step-multiplier) err-invalid-surge-params)
        
        (var-set surge-enabled enabled)
        (var-set surge-demand-threshold demand-threshold)
        (var-set surge-step-multiplier step-multiplier)
        (ok true)
    )
)

;; Read-only functions

;; Get institution details
(define-read-only (get-institution (institution-id uint))
    (map-get? institutions institution-id)
)

;; Get institution by owner
(define-read-only (get-institution-by-owner (owner principal))
    (match (map-get? institution-by-owner owner)
        institution-id (map-get? institutions institution-id)
        none
    )
)

;; Get institution metrics for surge pricing
(define-read-only (get-institution-metrics (institution-id uint))
    (map-get? institution-metrics institution-id)
)

;; Get current surge info for an institution
(define-read-only (get-surge-info (institution-id uint))
    (let (
        (metrics (default-to
            {active-rides: u0, available-drivers: u0, last-updated: u0}
            (map-get? institution-metrics institution-id)))
        (surge-mult (calculate-surge-multiplier institution-id))
    )
        (ok {
            institution-id: institution-id,
            active-rides: (get active-rides metrics),
            available-drivers: (get available-drivers metrics),
            surge-multiplier: surge-mult,
            surge-enabled: (var-get surge-enabled),
            demand-threshold: (var-get surge-demand-threshold),
            last-updated: (get last-updated metrics)
        })
    )
)

;; Get ride details
(define-read-only (get-ride (ride-id uint))
    (map-get? rides ride-id)
)

;; Get rider info
(define-read-only (get-rider (rider principal))
    (map-get? riders rider)
)

;; Get driver info
(define-read-only (get-driver (driver principal))
    (map-get? drivers driver)
)

;; Get ride payment info
(define-read-only (get-ride-payment (ride-id uint))
    (map-get? ride-payments ride-id)
)

;; Get current ride counter
(define-read-only (get-ride-counter)
    (var-get ride-counter)
)

;; Get current institution counter
(define-read-only (get-institution-counter)
    (var-get institution-counter)
)

;; Get platform fee
(define-read-only (get-platform-fee)
    (var-get platform-fee)
)

;; Get surge pricing parameters
(define-read-only (get-surge-parameters)
    (ok {
        enabled: (var-get surge-enabled),
        demand-threshold: (var-get surge-demand-threshold),
        step-multiplier: (var-get surge-step-multiplier),
        min-multiplier: min-surge-multiplier,
        max-multiplier: max-surge-multiplier
    })
)

;; Get distance between two points (simplified calculation)
(define-read-only (get-distance (lat1 int) (lng1 int) (lat2 int) (lng2 int))
    (begin
        (asserts! (is-valid-coordinates lat1 lng1) err-invalid-coordinates)
        (asserts! (is-valid-coordinates lat2 lng2) err-invalid-coordinates)
        (ok (calculate-simple-distance lat1 lng1 lat2 lng2))
    )
)

;; Get available drivers by institution
(define-read-only (get-drivers-by-institution (institution-id uint))
    (begin
        (asserts! (> institution-id u0) err-invalid-input)
        (ok {
            institution-id: institution-id,
            is-active: (validate-institution-exists-and-active institution-id)
        })
    )
)

;; Admin functions (contract owner only)

;; Update platform fee
(define-public (update-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-valid-fee new-fee) err-invalid-fee)
        (var-set platform-fee new-fee)
        (ok true)
    )
)