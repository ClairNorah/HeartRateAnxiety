import SwiftUI

struct CurrentHeartRateView: View {
    var value: Int
    @State private var petalVisibility: [Bool] // Array to track visibility of each petal
    let numberOfPetals = 6 // Number of petals
    let petalColors: [Color] = [.red, .yellow, .blue, .green, .orange, .purple] // Different petal colors

    init(value: Int) {
        self.value = value
        // Initially, all petals are visible
        _petalVisibility = State(initialValue: Array(repeating: true, count: numberOfPetals))
    }

    var body: some View {
        ZStack {
            // Generate petals in a circular pattern
            ForEach(0..<numberOfPetals, id: \.self) { i in // Use id: \.self to ensure the loop works
                let angle = Double(i) * (2 * .pi) / Double(numberOfPetals) // Calculate angle for each petal
                PetalView(
                    angle: angle,
                    petalColor: petalColors[i % petalColors.count],
                    isVisible: $petalVisibility[i] // Bind visibility to each petal
                )
            }

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
        .padding()
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

struct CurrentHeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentHeartRateView(value: 75)
    }
}
