import Foundation
import HealthKit
import Combine

class HeartRateMeasurementService: ObservableObject {
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var timer: Timer? // Timer for simulated heart rate in simulator
    
    @Published var currentHeartRate: Int = 0 // Published property for updates
    @Published var heartRateVariability: Double = 0.0 // New property for HRV

    private var heartRateSamples: [Int] = [] // Store recent heart rate samples for 5-min HRV calculation

    // Initialize and request permissions
    init() {
        #if targetEnvironment(simulator)
        startHeartRateSimulation(isRandom: true) // Use simulated heart rate in simulator
        #else
        requestAuthorization() // Real device uses HealthKit authorization
        #endif
    }

    private func startHeartRateSimulation(isRandom: Bool) {
        self.currentHeartRate = isRandom ? Int.random(in: 55...100) : 55
        var targetHeartRate = self.currentHeartRate
        var increasing = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isRandom {
                targetHeartRate += Int.random(in: -2...2)
                targetHeartRate = min(max(targetHeartRate, 55), 100)
                if self.currentHeartRate < targetHeartRate {
                    self.currentHeartRate += 1
                } else if self.currentHeartRate > targetHeartRate {
                    self.currentHeartRate -= 1
                }
            } else {
                if increasing {
                    self.currentHeartRate += 1
                    if self.currentHeartRate >= 100 {
                        increasing = false
                    }
                } else {
                    self.currentHeartRate -= 1
                    if self.currentHeartRate <= 55 {
                        increasing = true
                    }
                }
            }
            self.updateHRV() // Update HRV based on new heart rate
        }
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                self.startHeartRateQuery()
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func startHeartRateQuery() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.process(samples: samples, error: error)
        }
        query.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.process(samples: samples, error: error)
        }
        healthStore.execute(query)
        self.heartRateQuery = query
    }
    
    private func process(samples: [HKSample]?, error: Error?) {
        guard error == nil else {
            print("Failed to fetch heart rate data: \(error!.localizedDescription)")
            return
        }
        if let samples = samples as? [HKQuantitySample], !samples.isEmpty {
            let latestSample = samples.last!
            let heartRateUnit = HKUnit(from: "count/min")
            let heartRateValue = latestSample.quantity.doubleValue(for: heartRateUnit)
            DispatchQueue.main.async {
                self.currentHeartRate = Int(heartRateValue)
                self.heartRateSamples.append(self.currentHeartRate) // Add to samples
                if self.heartRateSamples.count > 300 { // Limit to last 300 samples (5 minutes at 1 sample/second)
                    self.heartRateSamples.removeFirst()
                }
                self.updateHRV() // Calculate HRV
            }
        }
    }

    // Calculate HRV based on 5-minute window of recent heart rate samples
    private func updateHRV() {
        guard heartRateSamples.count >= 2 else { return }
        
        // Simple HRV calculation: standard deviation of heart rate samples
        let mean = Double(heartRateSamples.reduce(0, +)) / Double(heartRateSamples.count)
        let variance = heartRateSamples.map { pow(Double($0) - mean, 2.0) }.reduce(0, +) / Double(heartRateSamples.count)
        self.heartRateVariability = sqrt(variance) // HRV as standard deviation
    }
    
    deinit {
        timer?.invalidate()
    }
}

