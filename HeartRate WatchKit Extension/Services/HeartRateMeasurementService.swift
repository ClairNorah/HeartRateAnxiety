import Combine
import SwiftUI

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0
    
    private var timers: Set<AnyCancellable> = [] // Store both timers in a set

    init() {
        startUpdatingHRV()
    }

    private func startUpdatingHRV() {
        // Timer for 1-minute HRV updates
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateHRV()
                self?.logHRV(for: 60) // Log HRV for 1-minute interval
            }
            .store(in: &timers) // Store this timer in the set
    }

    private func updateHRV() {
        // Calculate HRV based on current heart rate (example calculation)
        heartRateVariability = calculateHRV(from: currentHeartRate)
    }

    private func calculateHRV(from heartRate: Int) -> Double {
        // Example HRV calculation based on heart rate
        // You can replace this with a real HRV calculation formula
        let hrv = Double(100 - heartRate) // This is a placeholder; real formula needed
        return max(0, min(hrv, 100)) // Ensure HRV stays within a reasonable range
    }

    private func logHRV(for interval: Int) {
        print("HRV at \(interval) seconds: \(heartRateVariability) ms")
    }
}
