import SwiftUI

struct HeartRateHistoryView: View {
    var hrv: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HRV (RMSSD): \(String(format: "%.2f", hrv)) ms")
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
    }
}

struct HeartRateHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateHistoryView(hrv: 45.5)
    }
}

