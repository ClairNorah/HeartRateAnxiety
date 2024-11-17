import SwiftUI

struct InteractionSelectionView: View {
    // States to track if a specific view should be shown
    @State private var showFlowerView = false
    @State private var showCartoonView = false
    @State private var showAnotherView = false
    @State private var showNoMovingView = false

    var body: some View {
        VStack {
            Text("Select an Interaction")
                .font(.largeTitle)
                .padding()

            // Button for Flower Interaction
            Button(action: {
                showFlowerView = true
            }) {
                Text("Emoji Big")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Button for Cartoon Character Interaction
            Button(action: {
                showCartoonView = true
            }) {
                Text("Default")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Button for Another Interaction
            Button(action: {
                showAnotherView = true
            }) {
                Text("Emoji small ")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Button for Another Interaction
            Button(action: {
                showNoMovingView = true
            }) {
                Text("Emoji not moving ")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        // Flower interaction full screen cover
        .fullScreenCover(isPresented: $showFlowerView) {
            CurrentHeartRateView(value: 70)
        }
        // Cartoon characters interaction full screen cover
        .fullScreenCover(isPresented: $showCartoonView) {
            CartoonCharacterView(value: 70)
        }
        // Another interaction full screen cover
        .fullScreenCover(isPresented: $showAnotherView) {
            AnotherInteractionView(value: 70)
        }
    }
}

struct InteractionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionSelectionView()
    }
}
