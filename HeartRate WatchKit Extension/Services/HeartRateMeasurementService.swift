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
        // Sample HRV every 30 seconds and 1 minute
        
        // Timer for 30-second HRV updates
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateHRV()
                self?.logHRV(for: 30)
            }
            .store(in: &timers) // Store this timer in the set
        
        // Timer for 1-minute HRV updates
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.logHRV(for: 60)
            }
            .store(in: &timers) // Store this timer in the set
    }

    private func updateHRV() {
        // Placeholder: Replace with real HRV calculation
        heartRateVariability = Double.random(in: 20.0...80.0)
    }

    private func logHRV(for interval: Int) {
        print("HRV at \(interval) seconds: \(heartRateVariability) ms")
    }
}

