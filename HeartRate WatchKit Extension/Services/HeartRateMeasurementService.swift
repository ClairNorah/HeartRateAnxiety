import Combine
import SwiftUI

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0
    @Published var numberOfPetals: Int = 6
    @Published var petalColors: [Color] = [.yellow, .blue, .red, .green, .orange, .purple]
    @Published var petalVisibility: [Bool] = [true, true, true, true, true, true]
    @Published var scale: CGFloat = 1.0
    @Published var rotationAngle: Angle = .zero
    
    private var timer: AnyCancellable?
    
    init() {
        startUpdatingHRV()
    }

    private func startUpdatingHRV() {
        // Sample HRV every 30 seconds
        timer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateHRV()
            }
    }

    private func updateHRV() {
        // Placeholder: Replace with real HRV calculation
        heartRateVariability = Double.random(in: 20.0...80.0)
        currentHeartRate = Int.random(in: 60...100) // Simulate changing heart rate for demo
        print("Updated HRV: \(heartRateVariability) ms") // Log the updated HRV value
    }
}

