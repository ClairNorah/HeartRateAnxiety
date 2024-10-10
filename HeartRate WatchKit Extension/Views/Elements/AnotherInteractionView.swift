import SwiftUI

struct AnotherInteractionView: View {
    var body: some View {
        VStack {
            Text("Another Custom Interaction")
                .font(.largeTitle)
                .padding()

            // This is a dummy interaction view for testing/preview purposes
            Image(systemName: "star.circle.fill")
                .resizable()
                .frame(width: 200, height: 200)
                .foregroundColor(.purple)

            Spacer()
        }
        .padding()
    }
}

// Dummy preview file for AnotherInteractionView
struct AnotherInteractionView_Previews: PreviewProvider {
    static var previews: some View {
        AnotherInteractionView()
    }
}
