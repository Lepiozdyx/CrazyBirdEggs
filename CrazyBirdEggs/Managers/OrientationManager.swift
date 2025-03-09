import SwiftUI
import Combine

class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @Published var isLandscape: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Активация отслеживания смены ориентации
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // Подписка на уведомления об изменении ориентации
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main) // Добавляем задержку для избежания множественных вызовов
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateOrientation()
            }
            .store(in: &cancellables)
            
        // Начальная проверка ориентации при инициализации
        updateOrientation()
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    func updateOrientation() {
        // Сначала получаем текущее окно для более надежного определения ориентации
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        if let interfaceOrientation = windowScene?.interfaceOrientation {
            // Используем ориентацию интерфейса, которая более надежна для UI
            isLandscape = interfaceOrientation.isLandscape
            
            // Присваиваем соответствующее значение для ориентации устройства
            // Это более согласованный подход
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
                // Для неизвестных случаев используем текущую ориентацию устройства
                orientation = UIDevice.current.orientation
            }
        } else {
            // Запасной вариант, если windowScene недоступен
            let deviceOrientation = UIDevice.current.orientation
            
            // Проверяем, что ориентация не неизвестна и не лицом вверх/вниз
            if deviceOrientation.isValidInterfaceOrientation {
                orientation = deviceOrientation
                isLandscape = deviceOrientation.isLandscape
            } else {
                // Для некорректных ориентаций пытаемся найти активную сцену
                let activeWindowScene = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .first as? UIWindowScene
                
                let statusBarOrientation = activeWindowScene?.interfaceOrientation
                isLandscape = statusBarOrientation?.isLandscape ?? false
            }
        }
        
        // Вызываем обновление для уведомления подписчиков
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
                // Экран предупреждения
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
            // Перепроверяем при каждом изменении ориентации
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
            // Для случаев когда маска содержит и landscape и portrait (.all, .allButUpsideDown)
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
