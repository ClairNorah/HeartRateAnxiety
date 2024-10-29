import SwiftUI

struct HeartRateMeasurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()

    var body: some View {
        VStack {
            Spacer()

            CurrentHeartRateView(value: heartRateMeasurementService.currentHeartRate)

            Spacer()

            // Display current heart rate and HRV
            HeartRateHistoryView(
                /*title: "Current",
                value: heartRateMeasurementService.currentHeartRate,*/
                hrv: heartRateMeasurementService.heartRateVariability
            )
        }
        .padding()
        .onReceive(heartRateMeasurementService.$currentHeartRate) { newHeartRate in
            print("Current Heart Rate: \(newHeartRate)") // For debugging
        }
    }
}

struct HeartRateMeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateMeasurementView()
    }
}
