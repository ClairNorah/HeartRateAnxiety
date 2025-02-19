import Foundation
import Combine

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0
    @Published var rrIntervals: [Double] = [] // Store RR intervals

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Simulate heart rate updates every few seconds (Replace with real data)
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateHeartRate()
            }
            .store(in: &cancellables)
    }

    private func updateHeartRate() {
        let newHR = Int.random(in: 60...100) // Simulated HR
        let newRRIntervals = generateRandomRRIntervals(for: newHR) // Simulate RR intervals
        let timestamp = Date().formattedDateString() // Get formatted timestamp

        DispatchQueue.main.async {
            self.currentHeartRate = newHR
            self.rrIntervals = newRRIntervals
            self.heartRateVariability = self.calculateHRV(from: newRRIntervals)
            
            // **Log values in the console**
            print("Timestamp: \(timestamp), HR: \(self.currentHeartRate), RR Intervals: \(self.rrIntervals)")
        }
    }

    private func generateRandomRRIntervals(for hr: Int) -> [Double] {
        let rrInterval = 60_000.0 / Double(hr) // RR in milliseconds
        return (1...5).map { _ in rrInterval + Double.random(in: -10...10) } // Add small variations
    }

    private func calculateHRV(from rrIntervals: [Double]) -> Double {
        guard rrIntervals.count > 1 else { return 0.0 }
        let meanRR = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let squaredDiffs = rrIntervals.map { pow($0 - meanRR, 2) }
        return sqrt(squaredDiffs.reduce(0, +) / Double(rrIntervals.count))
    }
}

// **Helper Extension for Formatting Date**
extension Date {
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
