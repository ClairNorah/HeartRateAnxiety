import Foundation

struct InteractionLogger {
    static var interactionTimestamps: [Date] = []

    static func logInteraction() {
        interactionTimestamps.append(Date())
    }
    
    static func saveInteractionsToCSV() {
        let fileName = "InteractionsLog.csv"
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = directoryPath.appendingPathComponent(fileName)
        
        var csvText = "Timestamp\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for date in interactionTimestamps {
            let formattedDate = dateFormatter.string(from: date)
            csvText.append("\(formattedDate)\n")
        }
        
        do {
            try csvText.write(to: filePath, atomically: true, encoding: .utf8)
            print("File saved at: \(filePath.path)")
        } catch {
            print("Failed to write file: \(error)")
        }
    }
}
