import SwiftUI
import Combine

struct PetalView: View {
    var angle: Double // Angle at which the petal is positioned around the center
    var petalColor: Color // Color of the petal
    @Binding var isVisible: Bool // Binding to track visibility
    @State private var cancellables = Set<AnyCancellable>() // To hold references to cancellable objects

    var body: some View {
        if isVisible {
            Ellipse()
                .fill(petalColor)
                .frame(width: 20, height: 50) // Elongated petal shape
                .offset(x: 0, y: -60) // Position each petal away from the center
                .rotationEffect(Angle(radians: angle)) // Rotate each petal according to its angle
                .onTapGesture {
                    // When tapped, make the petal disappear
                    isVisible = false
                    
                    // Make it reappear after 4 seconds (change this value for longer/shorter duration)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        isVisible = true // Reappear the petal
                    }
                }
                .animation(.easeInOut, value: isVisible) // Smooth disappearing animation
        }
    }
}

struct PetalView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with petal visible
        PetalView(angle: 0, petalColor: .red, isVisible: .constant(true))
    }
}
