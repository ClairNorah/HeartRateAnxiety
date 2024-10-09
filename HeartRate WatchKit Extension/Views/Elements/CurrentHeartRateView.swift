import SwiftUI

struct CurrentHeartRateView: View {
    var flowerImageName: String
    var value: Int
    @State private var rotation: Double = 0 // State variable for rotation angle
    @GestureState private var dragOffset = CGSize.zero // To track drag offset

    var body: some View {
        VStack {
            Text(String(value))
                .fontWeight(.medium)
                .font(.system(size: 30))

            // Display the custom flower image based on heart rate
            Image(flowerImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100) // Adjust this size to make it larger
                .rotationEffect(.degrees(rotation + dragOffset.width)) // Apply rotation effect based on drag
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation // Update the drag offset
                        }
                        .onEnded { value in
                            // Update the rotation based on the final drag distance
                            rotation += value.translation.width
                        }
                )
        }
        .animation(.easeInOut, value: dragOffset) // Smooth animation for rotation
    }
}

struct CurrentHeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentHeartRateView(flowerImageName: "red_flower", value: 72) // Example preview
    }
}
