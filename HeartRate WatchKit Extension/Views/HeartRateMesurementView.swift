import SwiftUI

struct HeartRateMeasurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    @State private var isInteracting = false

    var body: some View {
        VStack {
            Spacer()

            CurrentHeartRateView(value: heartRateMeasurementService.currentHeartRate)

            Spacer()

            // Display current heart rate and HRV
            HeartRateHistoryView(
                hrv: heartRateMeasurementService.heartRateVariability
            )
        }
        .padding()
        .onAppear {
            InteractionLogger.logInteraction() // Log initial view appearance
        }
        .onDisappear {
            InteractionLogger.saveInteractionsToCSV() // Save interactions to CSV when view disappears
        }
        .onReceive(heartRateMeasurementService.$currentHeartRate) { newHeartRate in
            print("Current Heart Rate: \(newHeartRate)") // For debugging
        }
        .gesture(
            TapGesture()
                .onEnded {
                    isInteracting = true
                    InteractionLogger.logInteraction() // Log any tap interaction
                }
        )
    }
}

struct HeartRateMeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateMeasurementView()
    }
}
