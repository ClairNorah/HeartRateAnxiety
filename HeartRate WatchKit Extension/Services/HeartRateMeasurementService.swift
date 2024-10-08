import Foundation
import HealthKit
import Combine

class HeartRateMeasurementService: ObservableObject {
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    @Published var currentHeartRate: Int = 0 // Published property for updates

    // Initialize and request permissions
    init() {
        requestAuthorization()
    }

    // Request HealthKit authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                self.startHeartRateQuery()
            } else {
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                } else {
                    print("Authorization failed for an unknown reason.")
                }
            }
        }
    }
    
    // Start monitoring heart rate
    private func startHeartRateQuery() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.process(samples: samples, error: error)
        }

        query.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.process(samples: samples, error: error)
        }

        healthStore.execute(query)
        self.heartRateQuery = query
    }
    
    // Process heart rate samples
    private func process(samples: [HKSample]?, error: Error?) {
        guard error == nil else {
            print("Failed to fetch heart rate data: \(error!.localizedDescription)")
            return
        }

        if let samples = samples as? [HKQuantitySample], !samples.isEmpty {
            // Use the latest sample for current heart rate
            let latestSample = samples.last!
            let heartRateUnit = HKUnit(from: "count/min")
            let heartRateValue = latestSample.quantity.doubleValue(for: heartRateUnit)

            DispatchQueue.main.async {
                self.currentHeartRate = Int(heartRateValue)
                
                // Determine which flower to show
                let flowerName = self.flowerImageName(for: self.currentHeartRate)
                
                // Print the current heart rate and corresponding flower
                print("Updated heart rate: \(self.currentHeartRate), Flower: \(flowerName)") // Debug output
            }
        }
    }

    // Function to determine which flower to show based on heart rate
    private func flowerImageName(for currentHeartRate: Int) -> String {
        switch currentHeartRate {
        case ..<70:
            return "green_flower" // Green for heart rate below 70
        case 70..<80:
            return "orange_flower" // Orange for heart rate between 70 and 80
        case 80...:
            return "red_flower" // Red for heart rate above 80
        default:
            return "green_flower" // Default to green if something goes wrong
        }
    }
}
