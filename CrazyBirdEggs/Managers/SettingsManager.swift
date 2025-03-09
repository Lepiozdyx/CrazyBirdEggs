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
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    private let appID: String
    private let appStoreURL: URL
    
    private init() {
        self.isMusicOn = defaults.bool(forKey: "musicOn")
        self.isSoundOn = defaults.bool(forKey: "soundOn")
        self.isVibrationOn = defaults.bool(forKey: "vibrationOn")
        #warning("appID")
        self.appID = ""
        self.appStoreURL = URL(string: "https://apps.apple.com/app/id\(appID)")!
        
        setupDefaultSettings()
        setupAudioSession()
        prepareBackgroundMusic()
        prepareTapSound()
        prepareFeedbackGenerator()
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
        guard isVibrationOn else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func getHeavyVibration() {
        getVibration(style: .heavy)
    }
    
    func getLightVibration() {
        getVibration(style: .light)
    }
    
    func getSuccessVibration() {
        guard isVibrationOn else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    func getErrorVibration() {
        guard isVibrationOn else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
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
    
    private func prepareFeedbackGenerator() {
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
    }
}
