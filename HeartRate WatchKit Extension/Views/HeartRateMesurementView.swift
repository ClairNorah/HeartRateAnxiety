import SwiftUI

struct HeartRateMeasurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    @State private var isInteracting = false

    var body: some View {
        VStack {
            Spacer()

            CurrentHeartRateView(hr: heartRateMeasurementService.currentHeartRate, hrv: heartRateMeasurementService.heartRateVariability)

            Spacer()

            // Display current HRV
            HeartRateHistoryView(hr: heartRateMeasurementService.currentHeartRate)
                .frame(maxWidth: .infinity, alignment: .leading
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

