import SwiftUI

@main
struct CrazyBirdEggsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onAppear {
                    // Принудительно активируем отслеживание ориентации при запуске
                    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Разрешаем все ориентации на уровне приложения
        // Конкретные ограничения реализуются через OrientationRestrictedView
        return [.portrait, .portraitUpsideDown, .landscape]
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Обновляем ориентацию при запуске приложения
        OrientationManager.shared.updateOrientation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Обновляем ориентацию при возвращении из фона
        OrientationManager.shared.updateOrientation()
    }
}
