import SwiftUI

@main
struct CrazyBirdEggsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onAppear {
                    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown, .landscape]
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        OrientationManager.shared.updateOrientation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        OrientationManager.shared.updateOrientation()
    }
}
