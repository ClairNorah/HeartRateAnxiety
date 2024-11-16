import Combine
import SwiftUI

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0
    private var heartRateManager = HeartRateManager()
    private var timers: Set<AnyCancellable> = []
    private var rrIntervals: [Double] = [] // Store derived RR intervals
    
    init() {
        startUpdatingHRV()
    }

    private func startUpdatingHRV() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateHRV()
                self?.logHRV(for: 60)
            }
            .store(in: &timers)
    }

    private func updateHRV() {
        // Fetch new heart rate samples
        heartRateManager.fetchHeartRateSamples {
            DispatchQueue.main.async {
                // Update the current heart rate
                self.currentHeartRate = Int(self.heartRateManager.heartRateSamples.last?.quantity.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0)

                // Update RR intervals
                self.calculateRRIntervals()

                // Calculate HRV from RR intervals
                self.calculateHRV()
            }
        }
    }

    private func calculateRRIntervals() {
        guard currentHeartRate > 0 else {
            print("Invalid heart rate: \(currentHeartRate)")
            return
        }
        
        // Calculate RR interval
        let rrInterval = 60.0 / Double(currentHeartRate)
        
        // Check if the RR interval is within a reasonable range
        if rrInterval >= 0.3 && rrInterval <= 1.2 {
            rrIntervals.append(rrInterval)
            print("Added RR Interval: \(rrInterval) seconds")
        } else {
            print("Filtered out unrealistic RR interval: \(rrInterval)")
        }

        // Limit the RR intervals to the last 5 minutes
        let maxIntervals = 300 // Assuming 60 BPM and 5 minutes
        if rrIntervals.count > maxIntervals {
            rrIntervals.removeFirst(rrIntervals.count - maxIntervals)
        }
    }


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


    private func logHRV(for interval: Int) {
        print("HRV at \(interval) seconds: \(heartRateVariability) ms")
    }
}
