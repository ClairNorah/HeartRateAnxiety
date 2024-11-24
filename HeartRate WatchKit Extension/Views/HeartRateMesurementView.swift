import SwiftUI

struct HeartRateMeasurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    @State private var isInteracting = false

    var body: some View {
        VStack {
            Spacer()

            CurrentHeartRateView(value: heartRateMeasurementService.currentHeartRate)

            Spacer()

            // Display current HRV
            HeartRateHistoryView(
                hrv: heartRateMeasurementService.heartRateVariability
            )
        }
        .padding()
        .onAppear {
            InteractionLogger.logInteraction()
        }
        .onDisappear {
            InteractionLogger.saveInteractionsToCSV()
        }
        .onReceive(heartRateMeasurementService.$currentHeartRate) { newHeartRate in
            print("Current Heart Rate: \(newHeartRate)")
        }
        .gesture(
            TapGesture()
                .onEnded {
                    isInteracting = true
                    InteractionLogger.logInteraction()
                }
        )
    }
}

