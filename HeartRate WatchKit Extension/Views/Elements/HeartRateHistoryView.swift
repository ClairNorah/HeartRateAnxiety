import SwiftUI

struct HeartRateHistoryView: View {
    var hrv: Double // Add HRV property

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            /*Text("HRV: \(String(format: "%.2f", hrv)) ms") // Display HRV in milliseconds
                .font(.system(size: 8))
                .foregroundColor(.gray)*/
        }
    }
}

struct HeartRateHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateHistoryView(hrv: 45.5) // Example HRV preview
    }
}
