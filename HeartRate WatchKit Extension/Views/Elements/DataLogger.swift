import Foundation

class DataLogger {
    static let shared = DataLogger() // Singleton instance

    private init() {} // Prevent multiple instances

    func saveRRInterval(timestamp: Date, rrInterval: Double) {
        let dateFormatter = ISO8601DateFormatter()
        let timestampString = dateFormatter.string(from: timestamp)

        let csvLine = "\(timestampString),\(rrInterval)\n"
        let fileURL = getDocumentsDirectory().appendingPathComponent("RRIntervals.csv")

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                if let data = csvLine.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try "Timestamp,RRInterval\n".write(to: fileURL, atomically: true, encoding: .utf8)
                try csvLine.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to write to CSV file: \(error.localizedDescription)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
