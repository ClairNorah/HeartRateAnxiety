import HealthKit

// HeartRateManager to handle HealthKit interactions and HRV calculation
class HeartRateManager {
    private var healthStore = HKHealthStore()
    var heartRateSamples: [HKQuantitySample] = []

    // Request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            completion(success)
        }
    }

    // Fetch heart rate samples
    func fetchHeartRateSamples(completion: @escaping () -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 10, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            if let samples = samples as? [HKQuantitySample] {
                self.heartRateSamples = samples
            }
            completion()
        }
        healthStore.execute(query)
    }

    // Calculate HRV based on the standard deviation of RR intervals
    func getHeartRateVariability() -> Double {
        guard heartRateSamples.count >= 2 else { return 0.0 }

        var rrIntervals: [Double] = []
        for i in 1..<heartRateSamples.count {
            let interval = heartRateSamples[i].startDate.timeIntervalSince(heartRateSamples[i - 1].startDate)
            rrIntervals.append(interval)
        }

        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let variance = rrIntervals.map { pow($0 - mean, 2.0) }.reduce(0, +) / Double(rrIntervals.count)
        let standardDeviation = sqrt(variance)

        return standardDeviation * 1000 // Convert to milliseconds
    }
}
