import SwiftUI

struct ContentView: View {
    @ObservedObject private var orientationManager = OrientationManager.shared
    
    var body: some View {
        MainMenuView()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    orientationManager.updateOrientation()
                }
            }
            .onAppear {
                orientationManager.updateOrientation()
            }
    }
}

#Preview {
    ContentView()
}
