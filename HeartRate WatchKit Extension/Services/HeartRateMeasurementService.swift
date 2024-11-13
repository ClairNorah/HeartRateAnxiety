import Combine
import SwiftUI

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0

    private var heartRateManager = HeartRateManager()
    private var timers: Set<AnyCancellable> = []

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
        // Fetch HRV using the HeartRateManager class
        heartRateManager.fetchHeartRateSamples {
            DispatchQueue.main.async {
                self.heartRateVariability = self.heartRateManager.getHeartRateVariability()
            }
        }
    }

    private func logHRV(for interval: Int) {
        print("HRV at \(interval) seconds: \(heartRateVariability) ms")
    }
}
