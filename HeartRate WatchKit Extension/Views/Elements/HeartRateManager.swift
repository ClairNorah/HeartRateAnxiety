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
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
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
            // Always subtract the previous sample's startDate from the current sample's startDate
            let interval = heartRateSamples[i].startDate.timeIntervalSince(heartRateSamples[i - 1].startDate)
            
            // If interval is negative, there may be a problem with the sample order
            if interval < 0 {
                print("Warning: Negative RR interval detected. Time intervals should be positive.")
            }
            
            rrIntervals.append(interval)
        }

        // Debug: print RR intervals to check if they make sense
        print("RR Intervals: \(rrIntervals)")

        // Calculate the mean of the RR intervals
        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)

        // Debug: print the mean RR interval
        print("Mean RR Interval: \(mean)")

        // Calculate the variance (average squared deviation from the mean)
        let variance = rrIntervals.map { pow($0 - mean, 2.0) }.reduce(0, +) / Double(rrIntervals.count)

        // Debug: print the variance
        print("Variance: \(variance)")

        // Calculate the standard deviation (square root of variance)
        let standardDeviation = sqrt(variance)

        // Debug: print the standard deviation
        print("Standard Deviation: \(standardDeviation)")

        // Convert to milliseconds if the time interval is in seconds (standard deviation in seconds * 1000)
        let hrvInMilliseconds = standardDeviation * 1000

        // Debug: print the final HRV in milliseconds
        print("HRV in Milliseconds: \(hrvInMilliseconds)")

        return hrvInMilliseconds
    }

}

