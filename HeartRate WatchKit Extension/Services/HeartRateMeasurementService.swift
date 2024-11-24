import Foundation
import Combine
import HealthKit

class HeartRateMeasurementService: ObservableObject {
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var simulationTimer: Timer? // Timer for simulated heart rate in simulator
    private var hrvTimer: Timer? // Timer for HRV updates

    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0

    private var rrIntervals: [Double] = []

    init() {
        #if targetEnvironment(simulator)
        startHeartRateSimulation(isRandom: true)
        #else
        requestAuthorization()
        #endif

        startHRVUpdateTimer()
    }
    
    private func startHeartRateSimulation(isRandom: Bool) {
        self.currentHeartRate = isRandom ? Int.random(in: 55...100) : 55
        var targetHeartRate = self.currentHeartRate
        var increasing = true

        simulationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
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

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set<HKObjectType> = [heartRateType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted.")
                self.startHeartRateQuery()
            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func startHeartRateQuery() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (query, samples, _, _, error) in
            self?.process(samples: samples, error: error)
        }

        query.updateHandler = { [weak self] (query, samples, _, _, error) in
            self?.process(samples: samples, error: error)
        }

        healthStore.execute(query)
    }

    private func process(samples: [HKSample]?, error: Error?) {
        guard error == nil else {
            print("Error fetching heart rate samples: \(error!.localizedDescription)")
            return
        }

        if let samples = samples as? [HKQuantitySample], !samples.isEmpty {
            let latestSample = samples.last!
            let heartRateUnit = HKUnit(from: "count/min")
            let heartRateValue = latestSample.quantity.doubleValue(for: heartRateUnit)

            DispatchQueue.main.async {
                self.currentHeartRate = Int(heartRateValue)

                // Simulate RR intervals based on heart rate
                let rrInterval = 300.0 / heartRateValue
                self.rrIntervals.append(rrInterval)
            }
        }
    }

    private func startHRVUpdateTimer() {
        hrvTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { [weak self] _ in
            self?.updateHRV()
        }
    }

    private func updateHRV() {
        guard rrIntervals.count >= 2 else { return }
        
        self.heartRateVariability = calculateRMSSD(rrIntervals: rrIntervals)
        print("HRV: \(self.heartRateVariability) ms")

        rrIntervals.removeAll()
    }

    private func calculateRMSSD(rrIntervals: [Double]) -> Double {
        let squaredDifferences = zip(rrIntervals, rrIntervals.dropFirst())
            .map { pow($1 - $0, 2) }
        let meanOfSquaredDifferences = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)
        return sqrt(meanOfSquaredDifferences) * 1000 // Convert to milliseconds
    }

    deinit {
        simulationTimer?.invalidate()
        hrvTimer?.invalidate()
    }
}
