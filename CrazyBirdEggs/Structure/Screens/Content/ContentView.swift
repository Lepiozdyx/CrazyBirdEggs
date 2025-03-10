import SwiftUI

struct ContentView: View {
    @StateObject private var root = AppStateManager()
    @ObservedObject private var orientationManager = OrientationManager.shared
    
    var body: some View {
        Group {
            switch root.appState {
            case .loading:
                LoadingView()
            case .webView:
                if let url = root.webManager.myURL {
                    WebViewManager(url: url, webManager: root.webManager)
                } else {
                    WebViewManager(url: WebManager.targetURL, webManager: root.webManager)
                }
            case .mainMenu:
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
        .onAppear {
            root.stateCheck()
        }
    }
}

#Preview {
    ContentView()
}
