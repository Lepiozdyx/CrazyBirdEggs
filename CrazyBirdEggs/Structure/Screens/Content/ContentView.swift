import SwiftUI

struct ContentView: View {
    var body: some View {
        MainMenuView()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                // Update the orientation in the manager with each change
                OrientationManager.shared.updateOrientation()
            }
    }
}

#Preview {
    ContentView()
}
