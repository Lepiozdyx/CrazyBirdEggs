import SwiftUI
import Combine

class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Активация отслеживания смены ориентации
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // Подписка на уведомления об изменении ориентации
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.orientation = UIDevice.current.orientation
                self.isLandscape = UIDevice.current.orientation.isLandscape
            }
            .store(in: &cancellables)
            
        // Начальная проверка ориентации при инициализации
        updateOrientation()
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    func updateOrientation() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if let interfaceOrientation = windowScene?.interfaceOrientation {
            isLandscape = interfaceOrientation.isLandscape
        } else {
            isLandscape = UIDevice.current.orientation.isLandscape
        }
    }
}

struct OrientationRestrictedView<Content: View>: View {
    @StateObject private var orientationManager = OrientationManager.shared
    @State private var showAlert = false
    
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
                // Экран предупреждения
                VStack(spacing: 20) {
                    Text("Rotate the device")
                        .font(.system(size: 32, weight: .bold, design: .default))
                    
                    Text(restrictionMessage)
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .multilineTextAlignment(.center)
                    
                    Image(systemName: "rectangle.portrait.rotate")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 10)
                )
            }
        }
        .onAppear {
            orientationManager.updateOrientation()
        }
    }
    
    private var isOrientationValid: Bool {
        switch requiredOrientation {
        case .landscape:
            return orientationManager.isLandscape
        case .portrait:
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
