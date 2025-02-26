import Foundation
import Combine
import SwiftUI

class HeartRateMeasurementService: ObservableObject {
    @Published var currentHeartRate: Int = 0
    @Published var heartRateVariability: Double = 0.0
    @Published var rrIntervals: [Double] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.updateHeartRate() }
            .store(in: &cancellables)
    }

    private func updateHeartRate() {
        let newHR = Int.random(in: 60...100)
        let newRRIntervals = generateRandomRRIntervals(for: newHR)
        let timestamp = Date().formattedDateString()

        DispatchQueue.main.async {
            self.currentHeartRate = newHR
            self.rrIntervals = newRRIntervals
            self.heartRateVariability = self.calculateHRV(from: newRRIntervals)

            print("Timestamp: \(timestamp), HR: \(self.currentHeartRate), RR Intervals: \(self.rrIntervals)")
            self.saveToCSV(timestamp: timestamp, heartRate: self.currentHeartRate, rrIntervals: self.rrIntervals)
        }
    }

    private func generateRandomRRIntervals(for hr: Int) -> [Double] {
        let rrInterval = 60_000.0 / Double(hr)
        return (1...5).map { _ in rrInterval + Double.random(in: -10...10) }
    }

    private func calculateHRV(from rrIntervals: [Double]) -> Double {
        guard rrIntervals.count > 1 else { return 0.0 }
        let meanRR = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let squaredDiffs = rrIntervals.map { pow($0 - meanRR, 2) }
        return sqrt(squaredDiffs.reduce(0, +) / Double(rrIntervals.count))
    }

    private func saveToCSV(timestamp: String, heartRate: Int, rrIntervals: [Double]) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("HeartRateData.csv")
        let rrIntervalsString = rrIntervals.map { String($0) }.joined(separator: ", ")
        let csvRow = "\(timestamp), \(heartRate), \(rrIntervalsString)\n"

        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = csvRow.data(using: .utf8) { fileHandle.write(data) }
                fileHandle.closeFile()
            }
        } else {
            let header = "Timestamp, Heart Rate, RR Intervals\n"
            try? header.write(to: fileURL, atomically: true, encoding: .utf8)
            if let data = csvRow.data(using: .utf8) { try? data.write(to: fileURL, options: .atomic) }
        }
    }
}

extension Date {
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
