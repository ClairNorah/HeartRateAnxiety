import SwiftUI

struct HeartRateHistoryView: View {
    var hr: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HR: \(hr)")
                .font(.system(size: 8))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct HeartRateHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateHistoryView(hr: 45)
    }
}

