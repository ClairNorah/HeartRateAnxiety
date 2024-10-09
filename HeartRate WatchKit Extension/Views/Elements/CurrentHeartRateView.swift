import SwiftUI
import Combine

struct CurrentHeartRateView: View {
    var value: Int
    @State private var petalVisibility: [Bool] // Array to track visibility of each petal
    let numberOfPetals = 6 // Number of petals
    let petalColors: [Color] = [.red, .yellow, .blue, .green, .orange, .purple] // Different petal colors
    @State private var rotationAngle: Angle = .zero // Track the rotation of the flower
    @State private var lastDragPosition: CGPoint? = nil // Track the last drag position
    @State private var cancellables = Set<AnyCancellable>() // To hold references to cancellable objects

    init(value: Int) {
        self.value = value
        // Initially, all petals are visible
        _petalVisibility = State(initialValue: Array(repeating: true, count: numberOfPetals))
    }

    var body: some View {
        ZStack {
            // Generate petals in a circular pattern and apply rotation only to this part
            ZStack {
                ForEach(0..<numberOfPetals, id: \.self) { i in
                    let angle = Double(i) * (2 * .pi) / Double(numberOfPetals) // Calculate angle for each petal
                    PetalView(
                        angle: angle,
                        petalColor: petalColors[i % petalColors.count],
                        isVisible: $petalVisibility[i] // Bind visibility to each petal
                    )
                }
            }
            .rotationEffect(rotationAngle) // Apply the rotation only to the petals

            // Circle with heart rate number
            Circle()
                .fill(heartRateColor(for: value)) // Color of the circle based on heart rate
                .frame(width: 70, height: 80) // Size of the circle
                .overlay(
                    Text(String(value))
                        .fontWeight(.medium)
                        .font(.system(size: 30))
                        .foregroundColor(.white) // Text color inside the circle
                )
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Calculate the change in angle based on the drag movement
                    if let lastPosition = lastDragPosition {
                        let deltaX = value.location.x - lastPosition.x
                        let deltaY = value.location.y - lastPosition.y
                        let angleChange = atan2(deltaY, deltaX)
                        rotationAngle += Angle(radians: Double(angleChange))
                    }
                    lastDragPosition = value.location
                }
                .onEnded { _ in
                    lastDragPosition = nil // Reset drag position when gesture ends
                }
        )
    }

    // Function to determine the color based on heart rate
    private func heartRateColor(for currentHeartRate: Int) -> Color {
        switch currentHeartRate {
        case ..<70:
            return .green // Green for heart rate below 70
        case 70..<80:
            return .orange // Orange for heart rate between 70 and 80
        case 80...:
            return .red // Red for heart rate above 80
        default:
            return .green // Default to green if something goes wrong
        }
    }
}
