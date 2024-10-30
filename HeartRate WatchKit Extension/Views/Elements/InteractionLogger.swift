// InteractionLogger.swift

import Foundation

struct InteractionLogger {
    static var interactionTimestamps: [Date] = []
    
    static func logInteraction() {
        interactionTimestamps.append(Date())
    }
    
    static func saveInteractionsToCSV() {
        let fileName = "InteractionsLog.csv"
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // Create CSV content
        var csvText = "Timestamp\n"
        for date in interactionTimestamps {
            csvText.append("\(date)\n")
        }

        // Write to file
        do {
            try csvText.write(to: filePath, atomically: true, encoding: .utf8)
            print("File saved at: \(filePath.path)") // Print file path to console
        } catch {
            print("Failed to write file: \(error)")
        }
    }
    
    static func resetLog() {
        interactionTimestamps.removeAll()
    }
}
