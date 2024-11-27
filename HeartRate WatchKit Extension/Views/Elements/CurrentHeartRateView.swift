import SwiftUI
import Combine

struct CurrentHeartRateView: View {
    var hr: Int
    var hrv: Double
    @State private var numberOfPetals: Int = 6 // Number of petals
    @State private var petalVisibility: [Bool] = [] // Adjust initial count
    let petalColors: [Color] = [.red, .yellow, .blue, .green, .orange, .purple] // Different petal colors
    @State private var rotationAngle: Angle = .zero // Track the rotation of the flower
    @State private var lastDragPosition: CGPoint? = nil // Track the last drag position
    @State private var scale: CGFloat = 1.0 // Scale for pulsing effect
    @State private var isAnimating = false // To track if the animation is running
    @State private var cancellables = Set<AnyCancellable>() // To hold references to cancellable objects
    @State private var inactivityTimer: AnyCancellable? // Timer for inactivity
    @State private var isInteracting = false // To track if the user is interacting
    @State private var previousHrv: Double = 0
    
    init(hr: Int, hrv: Double) {
        self.hr = hr;
        self.hrv = hrv
        
        // Initially, all petals are visible
        _petalVisibility = State(initialValue: Array(repeating: true, count: numberOfPetals))
    }

    var body: some View {
        ZStack {
            // Generate petals in a circular pattern and apply rotation only to this part
            ZStack {
                ForEach(0..<numberOfPetals, id: \.self) { i in
                    let angle = Double(i) * (2 * .pi) / Double(numberOfPetals) // Calculate angle for each petal
                    let color = i < petalColors.count ? petalColors[i % petalColors.count] : petalColors.randomElement() ?? .orange // Choose color or random fallback
                    PetalView(
                        angle: angle,
                        petalColor: color,
                        isVisible: $petalVisibility[i] // Bind visibility to each petal
                    )
                }
            }
            .scaleEffect(scale) // Apply the scaling effect to the entire petal ZStack
            //.rotationEffect(rotationAngle) // Apply the rotation only to the petals
            // Circle with heart rate number
            Circle()
                .fill(heartRateColor(for: hrv)) // Color of the circle based on heart rate variability
                .frame(width: 70, height: 80) // Size of the circle
                .scaleEffect(scale) // Apply the scaling effect
        }
        .rotationEffect(rotationAngle) // Apply the rotation effect to everything
        .onAppear {
            if petalVisibility.count != numberOfPetals {
                petalVisibility = Array(repeating: true, count: numberOfPetals)
            }
            ensurePetalVisibilityCount(for: numberOfPetals)
            startInactivityTimer()
        }
        .onDisappear {
            inactivityTimer?.cancel() // Cancel the timer when the view disappears
        }
        .onChange(of: hrv) { newHeartRateVariability in
            adjustNumberOfPetals(for: newHeartRateVariability)
            ensurePetalVisibilityCount(for: numberOfPetals)
            previousHrv = newHeartRateVariability // Update previousHeartRate to the new value
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

    private func ensurePetalVisibilityCount(for petals: Int) {
        if petalVisibility.count < petals {
            petalVisibility.append(contentsOf: Array(repeating: true, count: petals - petalVisibility.count))
        }
    }
    
    // Function to start pulse animation
    private func startPulseAnimation() {
        guard !isInteracting else { return } // Only start animation if not interacting
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
        isAnimating = false // Stop animation when user interacts
        scale = 1.0 // Reset scale to original size

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
    private func heartRateColor(for currentHRV: Double) -> Color {
        /*if currentHRV == 0 {
            // Generate a dynamic rainbow color
            return Color(hue: Double.random(in: 0...1), saturation: 1, brightness: 1)
        }*/
        if currentHRV == 0 {
            return .yellow // Placeholder color for "calculating" phase
        }
        switch currentHRV {
        case ..<40:
            return .red // Red for heart rate variability below 40
        case 41..<49:
            return .orange // Orange for heart rate variability
        case 50...:
            return .green  //Green for heart rate variability above 50

        default:
            return .yellow // Default to green if something goes wrong
        }
    }

    private func adjustNumberOfPetals(for currentHrv: Double) {
        let previousColor = heartRateColor(for: previousHrv)
        let currentColor = heartRateColor(for: currentHrv)

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
        previousHrv = currentHrv
    }
}
