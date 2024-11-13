import SwiftUI

struct HeartRateMeasurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    @State private var isInteracting = false

    var body: some View {
        VStack {
            Spacer()

            // Show the current heart rate value
            CurrentHeartRateView(value: heartRateMeasurementService.currentHeartRate)

            Spacer()

            // Show HRV value every 1 minute with adjusted font size
            Text("HRV: \(heartRateMeasurementService.heartRateVariability, specifier: "%.2f") ms")
                .font(.system(size: 12)) // Adjust the size as needed
                .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            InteractionLogger.logInteraction() // Log initial view appearance
        }
        .onDisappear {
            InteractionLogger.saveInteractionsToCSV() // Save interactions to CSV when view disappears
        }
        .onReceive(heartRateMeasurementService.$currentHeartRate) { newHeartRate in
            // Debugging: print current heart rate whenever it changes
            print("Current Heart Rate: \(newHeartRate)") // This will print in the console
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
