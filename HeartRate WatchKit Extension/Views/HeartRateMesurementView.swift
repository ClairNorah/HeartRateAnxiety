import SwiftUI // Ensure this is included at the top

// Main View to display heart rate measurement
struct HeartRateMeasurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()

    // Function to determine which flower to show based on heart rate
    func flowerImageName(for currentHeartRate: Int) -> String {
        switch currentHeartRate {
        case ..<70:
            return "green_flower" // Green for heart rate below 70
        case 70..<80:
            return "orange_flower" // Orange for heart rate between 70 and 80
        case 80...:
            return "red_flower" // Red for heart rate above 80
        default:
            return "green_flower" // Default to green if something goes wrong
        }
    }

    var body: some View {
        VStack {
            Spacer()

            // Pass the appropriate flower image based on heart rate
            CurrentHeartRateView(
                flowerImageName: flowerImageName(for: heartRateMeasurementService.currentHeartRate),
                value: heartRateMeasurementService.currentHeartRate
            )

            Spacer()
        }
        .padding()
        .onReceive(heartRateMeasurementService.$currentHeartRate) { newHeartRate in
            print("Current Heart Rate: \(newHeartRate)") // For debugging
        }
    }
}

// Preview provider for HeartRateMeasurementView
struct HeartRateMeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateMeasurementView()
    }
}
