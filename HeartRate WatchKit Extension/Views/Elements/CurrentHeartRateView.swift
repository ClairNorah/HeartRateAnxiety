import SwiftUI

struct CurrentHeartRateView: View {
    var flowerImageName: String
    @State var isAnimating = false
    var value: Int
    
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
                .animation(Animation.linear(duration: 0.5).repeatForever())
        }
        .onAppear {
            self.isAnimating = true
        }
    }
}

struct CurrentHeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentHeartRateView(flowerImageName: "red_flower", value: 72 ) // Example preview
    }
}
