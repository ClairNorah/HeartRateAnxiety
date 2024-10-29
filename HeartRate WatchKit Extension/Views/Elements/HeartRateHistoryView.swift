import SwiftUI

struct HeartRateHistoryView: View {
    //var title: String
    //var value: Int
    var hrv: Double // Add HRV property
    //var units = "BPM"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                /*Text(title)
                    .fontWeight(.regular)
                    .font(.system(size: 8))
                Text(String(value))
                    .fontWeight(.bold)
                    .font(.system(size: 16))
                    .foregroundColor(.accentColor) */
                /*VStack {
                    Text(units)
                        .font(.system(size: 6))
                        .foregroundColor(.accentColor)
                    Spacer()
                }*/
            }
            Text("HRV: \(String(format: "%.2f", hrv)) ms") // Display HRV in milliseconds
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
    }
}

struct HeartRateHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateHistoryView(hrv: 45.5) // Example HRV preview
    }
}
