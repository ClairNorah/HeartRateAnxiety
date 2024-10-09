import SwiftUI

struct PetalView: View {
    var angle: Double // Angle at which the petal is positioned around the center
    var petalColor: Color // Color of the petal
    @Binding var isVisible: Bool // Binding to track visibility

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
                }
                .animation(.easeInOut, value: isVisible) // Smooth disappearing animation
        }
    }
}
