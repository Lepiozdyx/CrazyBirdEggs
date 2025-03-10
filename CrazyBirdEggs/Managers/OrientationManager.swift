import SwiftUI
import Combine

class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @Published var isLandscape: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateOrientation()
            }
            .store(in: &cancellables)
            
        updateOrientation()
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    func updateOrientation() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        if let interfaceOrientation = windowScene?.interfaceOrientation {
            isLandscape = interfaceOrientation.isLandscape

            switch interfaceOrientation {
            case .landscapeLeft:
                orientation = .landscapeLeft
            case .landscapeRight:
                orientation = .landscapeRight
            case .portrait:
                orientation = .portrait
            case .portraitUpsideDown:
                orientation = .portraitUpsideDown
            default:
                orientation = UIDevice.current.orientation
            }
        } else {
            let deviceOrientation = UIDevice.current.orientation
            
            if deviceOrientation.isValidInterfaceOrientation {
                orientation = deviceOrientation
                isLandscape = deviceOrientation.isLandscape
            } else {
                let activeWindowScene = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .first as? UIWindowScene
                
                let statusBarOrientation = activeWindowScene?.interfaceOrientation
                isLandscape = statusBarOrientation?.isLandscape ?? false
            }
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

struct OrientationRestrictedView<Content: View>: View {
    @ObservedObject private var orientationManager = OrientationManager.shared
    
    let requiredOrientation: UIInterfaceOrientationMask
    let content: Content
    let restrictionMessage: String
    
    init(
        requiredOrientation: UIInterfaceOrientationMask,
        restrictionMessage: String = "Rotate the device",
        @ViewBuilder content: () -> Content
    ) {
        self.requiredOrientation = requiredOrientation
        self.restrictionMessage = restrictionMessage
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isOrientationValid {
                content
            } else {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    Image(.chickenBackground)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 450)
                    
                    Image(.table1)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 280)
                        .offset(y: 50)
                        .overlay {
                            VStack(spacing: 10) {
                                Text("Rotate the device")
                                    .font(.system(size: 26, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                
                                Text(restrictionMessage)
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                
                                Image(systemName: "rectangle.portrait.rotate")
                                    .font(.system(size: 30))
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .offset(y: 50)
                        }
                }
            }
        }
        .onAppear {
            orientationManager.updateOrientation()
        }
        .onChange(of: orientationManager.isLandscape) { _ in
            orientationManager.updateOrientation()
        }
    }
    
    private var isOrientationValid: Bool {
        switch requiredOrientation {
        case .landscape, .landscapeLeft, .landscapeRight:
            return orientationManager.isLandscape
        case .portrait, .portraitUpsideDown:
            return !orientationManager.isLandscape
        default:
            return true
        }
    }
}

extension UIInterfaceOrientationMask {
    static var landscape: UIInterfaceOrientationMask { .landscapeLeft.union(.landscapeRight) }
}

struct GameViewWrapper: View {
    let levelId: Int
    let appState: AppState
    
    var body: some View {
        OrientationRestrictedView(
            requiredOrientation: .landscape,
            restrictionMessage: "Use landscape orientation for better experience"
        ) {
            GameView(levelId: levelId, appState: appState)
        }
    }
}

#Preview {
    GameViewWrapper(levelId: 1, appState: AppState())
}
