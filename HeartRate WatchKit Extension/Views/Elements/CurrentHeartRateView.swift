import SwiftUI

struct CurrentHeartRateView: View {
    var flowerImageName: String
    @State private var isAnimating = false
    var value: Int // You might change this to @Binding<Int> if it needs to react to external changes

    var body: some View {
        VStack {
            Text(String(value))
                .fontWeight(.medium)
                .font(.system(size: 60))
            
            // Display the custom flower image based on heart rate
            Image(flowerImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100) // Adjust this size to make it larger
                .scaleEffect(self.isAnimating ? 1 : 0.8)
                .onAppear {
                    withAnimation(Animation.linear(duration: 0.5).repeatForever()) {
                        self.isAnimating = true
                    }
                }
        }
    }
}

struct CurrentHeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentHeartRateView(flowerImageName: "red_flower", value: 72) // Example preview
    }
}
