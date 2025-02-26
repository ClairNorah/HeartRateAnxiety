import Foundation

struct InteractionLogger {
    static var interactionTimestamps: [Date] = []

    static func logInteraction() {
        interactionTimestamps.append(Date())
    }
    
    static func saveInteractionsToCSV() {
        let fileName = "InteractionsLog.csv"
        
        // Change this path to your desired directory
        let directoryPath = "/Users/clairmutebi/Documents/GitHub/HeartRateAnxietyAnalysis/HeartRate WatchKit Extension/Views/Elements"
        let filePath = URL(fileURLWithPath: directoryPath).appendingPathComponent(fileName)
        
        // Create CSV content
        var csvText = "Timestamp\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Customize the date format as needed

        for date in interactionTimestamps {
            let formattedDate = dateFormatter.string(from: date)
            csvText.append("\(formattedDate)\n")
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
