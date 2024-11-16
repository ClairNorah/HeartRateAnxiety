import Combine
import SwiftUI
import HealthKit

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0
    private var timers: Set<AnyCancellable> = []
    private var rrIntervals: [Double] = [] // Store derived RR intervals
    private let healthStore = HKHealthStore()

    init() {
        startUpdatingHRV()
    }

    // Start fetching and updating HRV every 10 seconds
    private func startUpdatingHRV() {
        Timer.publish(every: 10, on: .main, in: .common) // Reduced from 60 to 10 seconds
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateHRV()
                self?.logHRV(for: 10) // Adjust interval for logging
            }
            .store(in: &timers)
    }

    // Fetch heart rate samples from HealthKit
    private func fetchHeartRateSamples(completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate data type is unavailable")
            return
        }

        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .minute, value: -5, to: endDate) ?? endDate // 5 minutes range

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)

        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                print("Error fetching heart rate samples: \(String(describing: error))")
                return
            }
            completion(samples)
        }

        healthStore.execute(query)
    }

    // Update the current heart rate and HRV calculation
    private func updateHRV() {
        // Fetch heart rate samples
        fetchHeartRateSamples { heartRateSamples in
            DispatchQueue.main.async {
                guard let lastSample = heartRateSamples.last else {
                    print("No heart rate samples available")
                    return
                }

                // Update the current heart rate
                self.currentHeartRate = Int(lastSample.quantity.doubleValue(for: .count().unitDivided(by: .minute())))

                // Calculate RR intervals
                self.calculateRRIntervals(from: heartRateSamples)

                // Calculate HRV from RR intervals
                self.calculateHRV()
            }
        }
    }

    // Calculate RR intervals from heart rate samples
    private func calculateRRIntervals(from heartRateSamples: [HKQuantitySample]) {
        var newRRIntervals: [Double] = []

        // Calculate RR intervals from time differences between consecutive samples
        for i in 1..<heartRateSamples.count {
            let prevSample = heartRateSamples[i - 1]
            let currentSample = heartRateSamples[i]

            // Calculate the RR interval as the time difference between samples (in seconds)
            let interval = currentSample.startDate.timeIntervalSince(prevSample.startDate)
            newRRIntervals.append(interval)
        }

        // Add the new RR intervals to the existing list
        rrIntervals.append(contentsOf: newRRIntervals)

        // Limit the RR intervals to the last 5 minutes (if needed)
        let maxIntervals = 300 // Assuming 60 BPM and 5 minutes
        if rrIntervals.count > maxIntervals {
            rrIntervals.removeFirst(rrIntervals.count - maxIntervals)
        }

        print("Current RR Intervals: \(rrIntervals)")
    }

    // Calculate HRV from RR intervals
    private func calculateHRV() {
        guard rrIntervals.count > 1 else {
            print("Not enough RR intervals to calculate HRV. Current count: \(rrIntervals.count)")
            heartRateVariability = 0.0
            return
        }

        // Calculate mean RR interval
        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        print("Mean RR Interval: \(mean) seconds")

        // Calculate variance and standard deviation
        let variance = rrIntervals.map { pow($0 - mean, 2) }.reduce(0, +) / Double(rrIntervals.count)
        print("Variance: \(variance)")

        let standardDeviation = sqrt(variance)
        print("Standard Deviation (HRV): \(standardDeviation) seconds")

        // Convert to milliseconds
        heartRateVariability = standardDeviation * 1000.0
        print("HRV in Milliseconds: \(heartRateVariability) ms")
    }

    // Log HRV data at regular intervals
    private func logHRV(for interval: Int) {
        print("HRV at \(interval) seconds: \(heartRateVariability) ms")
    }
}

