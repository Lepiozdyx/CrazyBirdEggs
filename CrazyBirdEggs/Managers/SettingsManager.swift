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
    
    private let defaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer?
    private var tapPlayer: AVAudioPlayer?
    
    private init() {
        self.isMusicOn = defaults.bool(forKey: "musicOn")
        self.isSoundOn = defaults.bool(forKey: "soundOn")
        
        setupDefaultSettings()
        setupAudioSession()
        prepareBackgroundMusic()
        prepareTapSound()
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
}
