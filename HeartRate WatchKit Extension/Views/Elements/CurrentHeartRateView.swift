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

            VStack {
                // Display heart rate in the center
                Text(String(value))
                    .fontWeight(.medium)
                    .font(.system(size: 30))
            }
        }
        .padding()
    }
}
