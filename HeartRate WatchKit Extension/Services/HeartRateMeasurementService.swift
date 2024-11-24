import Foundation
import HealthKit
import Combine

class HeartRateMeasurementService: ObservableObject {
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0 // Updated HRV value

    private var rrIntervals: [Double] = [] // Store RR intervals (ms)

    init() {
        #if targetEnvironment(simulator)
        startHeartRateSimulation(isRandom: true) // Use simulated heart rate in simulator
        #else
        requestAuthorization() // Real device uses HealthKit authorization
        #endif
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let rrType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType, rrType]) { success, error in
            if success {
                self.startHeartRateQuery()
                self.fetchRRIntervals()
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func startHeartRateQuery() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.processHeartRate(samples: samples, error: error)
        }
        query.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.processHeartRate(samples: samples, error: error)
        }
        healthStore.execute(query)
        self.heartRateQuery = query
    }

    private func processHeartRate(samples: [HKSample]?, error: Error?) {
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
            }
        }
    }

    func fetchRRIntervals() {
        let rrType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: rrType, predicate: nil, limit: 300, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            guard error == nil else {
                print("Failed to fetch RR intervals: \(error!.localizedDescription)")
                return
            }
            if let samples = samples as? [HKQuantitySample] {
                self?.rrIntervals = samples.map { $0.quantity.doubleValue(for: .secondUnit(with: .milli)) }
                DispatchQueue.main.async {
                    self?.updateHRV() // Update HRV based on the new RR intervals
                }
            }
        }
        healthStore.execute(query)
    }

    private func updateHRV() {
        guard rrIntervals.count >= 2 else { return }
        
        // Calculate HRV using RMSSD or SDNN
        self.heartRateVariability = calculateRMSSD(rrIntervals: rrIntervals)
        
        // Log detailed HRV information
        print("HRV (RMSSD): \(self.heartRateVariability) ms")
        print("RR Intervals: \(rrIntervals)")
    }


    private func calculateSDNN(rrIntervals: [Double]) -> Double {
        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let variance = rrIntervals.map { pow($0 - mean, 2.0) }.reduce(0, +) / Double(rrIntervals.count)
        return sqrt(variance)
    }

    private func calculateRMSSD(rrIntervals: [Double]) -> Double {
        let successiveDifferences = zip(rrIntervals, rrIntervals.dropFirst()).map { $1 - $0 }
        let squaredDifferences = successiveDifferences.map { pow($0, 2.0) }
        let meanSquare = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)
        return sqrt(meanSquare)
    }
}

