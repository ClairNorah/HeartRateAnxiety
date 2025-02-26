import SwiftUI

struct HeartRateMeasurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    @State private var isInteracting = false

    var body: some View {
        VStack {
            Spacer()

            CurrentHeartRateView(hr: heartRateMeasurementService.currentHeartRate, hrv: heartRateMeasurementService.heartRateVariability)

            Spacer()

            HeartRateHistoryView(hr: heartRateMeasurementService.currentHeartRate)
        }
        .padding()
        .onAppear {
            InteractionLogger.logInteraction() // Log interaction when the view appears
        }
        .onDisappear {
            InteractionLogger.saveInteractionsToCSV() // Save interactions when the view disappears
        }
        .onReceive(heartRateMeasurementService.$currentHeartRate) { newHeartRate in
            print("Current Heart Rate: \(newHeartRate)")
        }
        .gesture(
            TapGesture()
                .onEnded {
                    isInteracting = true
                    InteractionLogger.logInteraction() // Log interaction on tap
                }
        )
    }
}

// Assuming you have defined InteractionLogger elsewhere in your code.
