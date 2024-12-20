import SwiftUI
import Combine

struct CartoonCharacterView: View {
    var value: Int
    @State private var petalVisibility: [Bool]  = []  // Array to track visibility of each petal
    @State private var numberOfPetals: Int // Number of petals
    let petalColors: [Color] = [.red, .yellow, .blue, .green, .orange, .purple] // Different petal colors
    @State private var rotationAngle: Angle = .zero // Track the rotation of the flower
    @State private var lastDragPosition: CGPoint? = nil // Track the last drag position
    @State private var scale: CGFloat = 1.0 // Scale for pulsing effect
    @State private var isAnimating = false // To track if the animation is running
    @State private var cancellables = Set<AnyCancellable>() // To hold references to cancellable objects
    @State private var inactivityTimer: AnyCancellable? // Timer for inactivity
    @State private var isInteracting = false // To track if the user is interacting
    @State private var previousHeartRate: Int = 0
    
    init(value: Int) {
        self.value = value
        self.numberOfPetals = 6
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
                    .scaleEffect(scale) // Apply the scaling effect
                }
            }
            .rotationEffect(rotationAngle) // Apply the rotation only to the petals

            // Circle representing heart rate
            Circle()
                .fill(heartRateColor(for: value)) // Color of the circle based on heart rate
                .frame(width: 70, height: 80) // Size of the circle
                .scaleEffect(scale) // Apply the scaling effect
                // Comment out the overlay to remove heart rate number
                // .overlay(
                //     Text(String(value))
                //         .fontWeight(.medium)
                //         .font(.system(size: 30))
                //         .foregroundColor(.white) // Text color inside the circle
                // )
        }
        .onAppear {
            // Start the inactivity timer
            startInactivityTimer()
        }
        .onDisappear {
            inactivityTimer?.cancel() // Cancel the timer when the view disappears
        }
        // Update the petals count and color when the heart rate value changes
        .onChange(of: previousHeartRate) { newHeartRate in
            adjustNumberOfPetals(for: newHeartRate)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    isInteracting = true // User is interacting
                    // Reset the inactivity timer
                    resetInactivityTimer()
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

    // Function to start pulse animation
    private func startPulseAnimation() {
        isAnimating = true
        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            scale = 1.2 // Scale up
        }
    }

    // Function to start inactivity timer
    private func startInactivityTimer() {
        inactivityTimer = Timer
            .publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in // Use [self] instead of [weak self]
                if !isInteracting {
                    startPulseAnimation() // Start the pulse animation after 30 seconds
                }
            }
    }

    // Function to reset the inactivity timer
    private func resetInactivityTimer() {
        inactivityTimer?.cancel() // Cancel any existing timer
        isInteracting = false // Reset interaction flag

        // Set a new timer to start the pulse animation after 30 seconds of inactivity
        inactivityTimer = Timer
            .publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in // Use [self] instead of [weak self]
                if !isInteracting {
                    startPulseAnimation() // Start the pulse animation after 30 seconds
                }
            }
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

    private func adjustNumberOfPetals(for currentHeartRate: Int) {
        let previousColor = heartRateColor(for: previousHeartRate)
        let currentColor = heartRateColor(for: currentHeartRate)

        // Check if heart rate color is changing between zones
        if previousColor == .green && currentColor == .orange {
            numberOfPetals -= 1
        } else if previousColor == .orange && currentColor == .red {
            numberOfPetals -= 1
        } else if previousColor == .red && currentColor == .orange {
            numberOfPetals += 1
        } else if previousColor == .orange && currentColor == .green {
            numberOfPetals += 1
        }

        // Update previous heart rate
        previousHeartRate = currentHeartRate
    }
}
