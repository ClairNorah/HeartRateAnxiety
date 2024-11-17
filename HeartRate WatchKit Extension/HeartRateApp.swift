import SwiftUI

@main
struct HeartRateApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                InteractionSelectionView() // Ensure the spelling is correct here
                //InteractionSelectionView()
            }
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
