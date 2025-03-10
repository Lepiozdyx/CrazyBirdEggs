import SwiftUI

final class ReelViewModel: ObservableObject {
    @Published var rotationAngle: Double = 0
    @Published var isSpinning: Bool = false
    @Published var showReward: Bool = false
    @Published var rewardPoints: Int = 0
    @Published var isLocked: Bool = false
    @Published var showLockOverlay: Bool = false
    @Published var hoursRemaining: Int = 0
    
    #if DEBUG
    @Published var debugDisableLock: Bool = false
    #endif
    
    private var spinTimer: Timer?
    private var lockTimer: Timer?
    private var initialVelocity: Double = 1000
    private var decelerationRate: Double = 0.97
    private var currentVelocity: Double = 0
    private var lastUpdateTime: Date?
    
    private let userDefaultsLastSpinKey = "lastSpinTimestamp"
    
    init() {
        checkLockStatus()
    }
    
    func spinReel(onComplete: @escaping (Int) -> Void) {
        guard !isSpinning && !isLocked else { return }
        
        isSpinning = true
        showReward = false
        showLockOverlay = false
        currentVelocity = initialVelocity
        lastUpdateTime = Date()
        
        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let now = Date()
            let deltaTime = now.timeIntervalSince(self.lastUpdateTime ?? now)
            self.lastUpdateTime = now
            
            let angleChange = self.currentVelocity * deltaTime
            self.rotationAngle += angleChange
            
            self.currentVelocity *= self.decelerationRate
            
            if self.currentVelocity < 10 {
                timer.invalidate()
                self.spinTimer = nil
                
                let possibleRewards = [0, 100, 200, 300, 400, 500]
                self.rewardPoints = possibleRewards.randomElement() ?? 100
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    let sectorAngle = 360.0 / Double(possibleRewards.count)
                    let normalizedAngle = self.rotationAngle.truncatingRemainder(dividingBy: 360)
                    let targetAngle = round(normalizedAngle / sectorAngle) * sectorAngle
                    self.rotationAngle = targetAngle
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            self.showReward = true
                        }
                        
                        onComplete(self.rewardPoints)
                        
                        self.isSpinning = false
                        self.activateLock()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                self.showLockOverlay = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func activateLock() {
        #if DEBUG
        if debugDisableLock {
            isLocked = false
            return
        }
        #endif
        
        let now = Date()
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: userDefaultsLastSpinKey)
        
        isLocked = true
        startLockTimer()
    }
    
    private func startLockTimer() {
        updateRemainingTime()
        
        lockTimer?.invalidate()
        lockTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }
    
    private func updateRemainingTime() {
        #if DEBUG
        if debugDisableLock {
            isLocked = false
            showLockOverlay = false
            return
        }
        #endif
        
        guard let lastSpinTimestamp = UserDefaults.standard.object(forKey: userDefaultsLastSpinKey) as? Double else {
            isLocked = false
            showLockOverlay = false
            return
        }
        
        let lastSpinDate = Date(timeIntervalSince1970: lastSpinTimestamp)
        let now = Date()
        
        let timeElapsed = now.timeIntervalSince(lastSpinDate)
        let totalLockTime: TimeInterval = 24 * 3600
        
        if timeElapsed >= totalLockTime {
            isLocked = false
            showLockOverlay = false
            lockTimer?.invalidate()
            lockTimer = nil
        } else {
            let timeRemaining = totalLockTime - timeElapsed
            hoursRemaining = Int(ceil(timeRemaining / 3600))
            
            isLocked = true
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func checkLockStatus() {
        #if DEBUG
        if debugDisableLock {
            isLocked = false
            showLockOverlay = false
            return
        }
        #endif
        
        guard let lastSpinTimestamp = UserDefaults.standard.object(forKey: userDefaultsLastSpinKey) as? Double else {
            isLocked = false
            showLockOverlay = false
            return
        }
        
        let lastSpinDate = Date(timeIntervalSince1970: lastSpinTimestamp)
        let now = Date()
        let timeElapsed = now.timeIntervalSince(lastSpinDate)
        
        if timeElapsed < 24 * 3600 {
            isLocked = true
            showLockOverlay = true
            startLockTimer()
        } else {
            isLocked = false
            showLockOverlay = false
        }
    }
    
    #if DEBUG
    func resetLockForDebug() {
        isLocked = false
        showLockOverlay = false
        UserDefaults.standard.removeObject(forKey: userDefaultsLastSpinKey)
    }
    
    func setDebugTimer(hours: Int) {
        let now = Date()
        let timeToSubtract = TimeInterval((24 - hours) * 3600)
        let fakeSpinTime = now.addingTimeInterval(-timeToSubtract)
        
        UserDefaults.standard.set(fakeSpinTime.timeIntervalSince1970, forKey: userDefaultsLastSpinKey)
        
        isLocked = true
        startLockTimer()
        
        withAnimation {
            showLockOverlay = true
        }
    }
    #endif
    
    deinit {
        spinTimer?.invalidate()
        lockTimer?.invalidate()
    }
}
