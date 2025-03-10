import UIKit
import AVFoundation

@MainActor
final class SettingsManager: ObservableObject {
    
    static let shared = SettingsManager()
    
    @Published var isSoundOn: Bool {
        didSet {
            defaults.set(isSoundOn, forKey: "soundOn")
        }
    }
    
    @Published var isMusicOn: Bool {
        didSet {
            defaults.set(isMusicOn, forKey: "musicOn")
            
            if isMusicOn {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    @Published var isVibrationOn: Bool {
        didSet {
            defaults.set(isVibrationOn, forKey: "vibrationOn")
        }
    }
    
    private let defaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer?
    private var tapPlayer: AVAudioPlayer?
    private var mediumFeedbackGenerator: UIImpactFeedbackGenerator?
    private var lightFeedbackGenerator: UIImpactFeedbackGenerator?
    private var heavyFeedbackGenerator: UIImpactFeedbackGenerator?
    private var notificationFeedbackGenerator: UINotificationFeedbackGenerator?
    private let appID: String
    private let appStoreURL: URL
    private var isVibrationSupported: Bool
    
    private init() {
        self.isMusicOn = defaults.bool(forKey: "musicOn")
        self.isSoundOn = defaults.bool(forKey: "soundOn")
        self.isVibrationOn = defaults.bool(forKey: "vibrationOn")
        self.appID = "6743075101"
        self.appStoreURL = URL(string: "https://apps.apple.com/app/id\(appID)")!
        self.isVibrationSupported = UIDevice.current.hasHapticFeedback
        
        setupDefaultSettings()
        setupAudioSession()
        prepareBackgroundMusic()
        prepareTapSound()
        prepareFeedbackGenerators()
    }
    
    func toggleSound() {
        isSoundOn.toggle()
    }
    
    func getTapSound() {
        guard isSoundOn,
              let player = tapPlayer,
              !player.isPlaying else { return }
        
        player.play()
    }
    
    func toggleMusic() {
        isMusicOn.toggle()
    }
    
    func playBackgroundMusic() {
        guard isMusicOn,
              let player = audioPlayer,
              !player.isPlaying else { return }
        
        audioPlayer?.play()
    }
    
    func stopBackgroundMusic() {
        audioPlayer?.pause()
    }
    
    // MARK: - Vibration methods
    
    func toggleVibration() {
        isVibrationOn.toggle()
    }
    
    func getVibration(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isVibrationOn, isVibrationSupported else { return }
        
        switch style {
        case .light:
            lightFeedbackGenerator?.impactOccurred()
            lightFeedbackGenerator?.prepare()
        case .medium:
            mediumFeedbackGenerator?.impactOccurred()
            mediumFeedbackGenerator?.prepare()
        case .heavy:
            heavyFeedbackGenerator?.impactOccurred()
            heavyFeedbackGenerator?.prepare()
        default:
            mediumFeedbackGenerator?.impactOccurred()
            mediumFeedbackGenerator?.prepare()
        }
    }
    
    func getHeavyVibration() {
        guard isVibrationOn, isVibrationSupported else { return }
        heavyFeedbackGenerator?.impactOccurred()
        heavyFeedbackGenerator?.prepare()
    }
    
    func getLightVibration() {
        guard isVibrationOn, isVibrationSupported else { return }
        lightFeedbackGenerator?.impactOccurred()
        lightFeedbackGenerator?.prepare()
    }
    
    func getSuccessVibration() {
        guard isVibrationOn, isVibrationSupported else { return }
        notificationFeedbackGenerator?.notificationOccurred(.success)
        notificationFeedbackGenerator?.prepare()
    }
    
    func getErrorVibration() {
        guard isVibrationOn, isVibrationSupported else { return }
        notificationFeedbackGenerator?.notificationOccurred(.error)
        notificationFeedbackGenerator?.prepare()
    }
    
    func getWarningVibration() {
        guard isVibrationOn, isVibrationSupported else { return }
        notificationFeedbackGenerator?.notificationOccurred(.warning)
        notificationFeedbackGenerator?.prepare()
    }
    
    // MARK: - Rate method
    func rateApp() {
        let appStoreURL = "itms-apps://apps.apple.com/app/id\(appID)"
        if let url = URL(string: appStoreURL),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(self.appStoreURL)
        }
    }
    
    // MARK: - Private methods
    private func setupDefaultSettings() {
        if defaults.object(forKey: "soundOn") == nil {
            defaults.set(true, forKey: "soundOn")
            isSoundOn = true
        }
        
        if defaults.object(forKey: "musicOn") == nil {
            defaults.set(true, forKey: "musicOn")
            isMusicOn = true
        }
        
        if defaults.object(forKey: "vibrationOn") == nil {
            defaults.set(true, forKey: "vibrationOn")
            isVibrationOn = true
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    private func prepareBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func prepareTapSound() {
        guard let url = Bundle.main.url(forResource: "tap", withExtension: "mp3") else {
            return
        }
        
        do {
            tapPlayer = try AVAudioPlayer(contentsOf: url)
            tapPlayer?.numberOfLoops = 0
            tapPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func prepareFeedbackGenerators() {
        guard isVibrationSupported else { return }
        
        mediumFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        mediumFeedbackGenerator?.prepare()
        
        lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        lightFeedbackGenerator?.prepare()
        
        heavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyFeedbackGenerator?.prepare()
        
        notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator?.prepare()
    }
}

// MARK: - UIDevice Extension
extension UIDevice {
    var hasHapticFeedback: Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            let deviceType = UIDevice.current.model
            return deviceType.hasPrefix("iPhone") && !["iPhone1,", "iPhone2,", "iPhone3,", "iPhone4,", "iPhone5,", "iPhone6,", "iPhone8,"].contains(where: { deviceType.contains($0) })
        }
    }
}
