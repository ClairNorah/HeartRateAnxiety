import SwiftUI
import HealthKit

struct HeartRateMesurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    
    // Function to determine which flower to show based on heart rate
    func flowerImageName(for heartRate: Int) -> String {
        switch heartRate {
        case 0..<65:
            return "green_flower" // Low heart rate
        case 65..<100:
            return "yellow_flower" // Normal heart rate
        case 100..<150:
            return "orange_flower" // Slightly elevated heart rate
        default:
            return "red_flower" // High heart rate
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Pass the appropriate flower image based on the heart rate
            CurrentHeartRateView(
                flowerImageName: flowerImageName(for: heartRateMeasurementService.currentHeartRate),
                value: heartRateMeasurementService.currentHeartRate
            )
            
            if heartRateMeasurementService.currentHeartRate > 150 {
                Text("Keep calm\n🧘🏻")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
            } else {
                Text("Heart rate is normal\n👌🏼")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct HeartRateMesurementView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateMesurementView()
    }
}
