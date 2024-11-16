import SwiftUI
import Combine
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
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true) // Ascending order
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 10, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            if let samples = samples as? [HKQuantitySample] {
                self.heartRateSamples = samples
            }
            completion()
        }
        healthStore.execute(query)
    }

    func getHeartRateVariability() -> Double {
        // Ensure there are at least two samples to calculate HRV
        guard heartRateSamples.count >= 2 else { return 0.0 }

        var rrIntervals: [Double] = []
        
        // Calculate RR intervals (time difference between consecutive heart rate samples)
        for i in 1..<heartRateSamples.count {
            let interval = heartRateSamples[i].startDate.timeIntervalSince(heartRateSamples[i - 1].startDate)
            // Ignore intervals outside a plausible range (e.g., 300–1200 ms)
            if interval >= 0.3 && interval <= 1.2 {
                rrIntervals.append(interval)
            } else {
                print("Filtered out unrealistic RR interval: \(interval)")
            }
        }
        
        guard !rrIntervals.isEmpty else {
            print("No valid RR intervals found.")
            return 0.0
        }

        print("Filtered RR Intervals: \(rrIntervals)")

        // Calculate the mean of the RR intervals
        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        print("Mean RR Interval: \(mean)")

        // Calculate the variance (average squared deviation from the mean)
        let variance = rrIntervals.map { pow($0 - mean, 2.0) }.reduce(0, +) / Double(rrIntervals.count)
        print("Variance: \(variance)")

        // Calculate the standard deviation (square root of variance)
        let standardDeviation = sqrt(variance)
        print("Standard Deviation: \(standardDeviation)")

        // Convert to milliseconds if the time interval is in seconds
        let hrvInMilliseconds = standardDeviation * 1000
        print("HRV in Milliseconds: \(hrvInMilliseconds)")

        return hrvInMilliseconds
    }


}

