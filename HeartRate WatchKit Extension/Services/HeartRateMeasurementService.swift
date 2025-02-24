import Foundation
import Combine
import SwiftUI

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0
    @Published var rrIntervals: [Double] = [] // Store RR intervals

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Simulate heart rate updates every few seconds (Replace with real data)
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateHeartRate()
            }
            .store(in: &cancellables)
    }

    private func updateHeartRate() {
        let newHR = Int.random(in: 60...100) // Simulated HR
        let newRRIntervals = generateRandomRRIntervals(for: newHR) // Simulate RR intervals
        let timestamp = Date().formattedDateString() // Get formatted timestamp

        DispatchQueue.main.async {
            self.currentHeartRate = newHR
            self.rrIntervals = newRRIntervals
            self.heartRateVariability = self.calculateHRV(from: newRRIntervals)

            // Log values in the console
            print("Timestamp: \(timestamp), HR: \(self.currentHeartRate), RR Intervals: \(self.rrIntervals)")

            // Save values to CSV in the Documents folder
            self.saveToCSV(timestamp: timestamp, heartRate: self.currentHeartRate, rrIntervals: self.rrIntervals)
        }
    }

    private func generateRandomRRIntervals(for hr: Int) -> [Double] {
        let rrInterval = 60_000.0 / Double(hr) // RR in milliseconds
        return (1...5).map { _ in rrInterval + Double.random(in: -10...10) } // Add small variations
    }

    private func calculateHRV(from rrIntervals: [Double]) -> Double {
        guard rrIntervals.count > 1 else { return 0.0 }
        let meanRR = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let squaredDiffs = rrIntervals.map { pow($0 - meanRR, 2) }
        return sqrt(squaredDiffs.reduce(0, +) / Double(rrIntervals.count))
    }

    private func saveToCSV(timestamp: String, heartRate: Int, rrIntervals: [Double]) {
        // Get the Documents directory URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("HeartRateData.csv")

        // Create the CSV row
        let rrIntervalsString = rrIntervals.map { String($0) }.joined(separator: ", ")
        let csvRow = "\(timestamp), \(heartRate), \(rrIntervalsString)\n"

        // Write to the file
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = csvRow.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            }
        } else {
            // Create a new file and write the header
            let header = "Timestamp, Heart Rate, RR Intervals\n"
            try? header.write(to: fileURL, atomically: true, encoding: .utf8)
            if let data = csvRow.data(using: .utf8) {
                try? data.write(to: fileURL, options: .atomic)
            }
        }
    }
}

// Helper Extension for Formatting Date
extension Date {
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
