//import SwiftUI
//
//struct SpinReelView: View {
//    @StateObject private var reelViewModel = ReelViewModel()
//    @ObservedObject var appState: AppState
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Button {
//                SettingsManager.shared.getTapSound()
//                if !reelViewModel.isSpinning && !reelViewModel.isLocked {
//                    reelViewModel.spinReel(onComplete: { points in
//                        appState.addScore(points: points)
//                    })
//                }
//            } label: {
//                ZStack {
//                    HStack {
//                        // Отображение полученных очков
//                        if reelViewModel.showReward {
//                            Text("+\(reelViewModel.rewardPoints) points!")
//                                .font(.system(size: 24, weight: .bold, design: .serif))
//                                .foregroundColor(.yellow)
//                                .shadow(color: .black, radius: 1)
//                                .transition(.scale.combined(with: .opacity))
//                                .onAppear {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                        withAnimation {
//                                            reelViewModel.showReward = false
//                                        }
//                                    }
//                                }
//                        }
//                        
//                        Image(.reel)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth: 300)
//                            .rotationEffect(.degrees(reelViewModel.rotationAngle))
//                            .overlay {
//                                Image(.arrow)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .scaleEffect(0.9)
//                            }
//                    }
//                    
//                    if reelViewModel.isLocked {
//                        VStack(spacing: 10) {
//                            Image(systemName: "lock.fill")
//                                .font(.system(size: 50))
//                                .foregroundColor(.black)
//                            
//                            Text("\(reelViewModel.hoursRemaining)h")
//                                .font(.system(size: 30, weight: .bold, design: .rounded))
//                                .foregroundColor(.black)
//                                .shadow(color: .black, radius: 2)
//                        }
//                        .onAppear {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                withAnimation {
//                                    reelViewModel.showReward = false
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .buttonStyle(.plain)
//            .disabled(reelViewModel.isSpinning || reelViewModel.isLocked)
//        }
//        .onAppear {
//            reelViewModel.checkLockStatus()
//        }
//    }
//}
//
//final class ReelViewModel: ObservableObject {
//    @Published var rotationAngle: Double = 0
//    @Published var isSpinning: Bool = false
//    @Published var showReward: Bool = false
//    @Published var rewardPoints: Int = 0
//    @Published var isLocked: Bool = false
//    @Published var hoursRemaining: Int = 0
//    
//    private var spinTimer: Timer?
//    private var lockTimer: Timer?
//    private var initialVelocity: Double = 1000
//    private var decelerationRate: Double = 0.97
//    private var currentVelocity: Double = 0
//    private var lastUpdateTime: Date?
//    
//    private let userDefaultsLastSpinKey = "lastSpinTimestamp"
//    
//    init() {
//        checkLockStatus()
//    }
//    
//    func spinReel(onComplete: @escaping (Int) -> Void) {
//        guard !isSpinning && !isLocked else { return }
//        
//        isSpinning = true
//        showReward = false
//        currentVelocity = initialVelocity
//        lastUpdateTime = Date()
//        
//        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
//            guard let self = self else {
//                timer.invalidate()
//                return
//            }
//            
//            let now = Date()
//            let deltaTime = now.timeIntervalSince(self.lastUpdateTime ?? now)
//            self.lastUpdateTime = now
//            
//            let angleChange = self.currentVelocity * deltaTime
//            self.rotationAngle += angleChange
//            
//            self.currentVelocity *= self.decelerationRate
//            
//            if self.currentVelocity < 10 {
//                timer.invalidate()
//                self.spinTimer = nil
//                
//                let possibleRewards = [0, 100, 200, 300, 400, 500]
//                self.rewardPoints = possibleRewards.randomElement() ?? 100
//                
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                    let sectorAngle = 360.0 / Double(possibleRewards.count)
//                    let normalizedAngle = self.rotationAngle.truncatingRemainder(dividingBy: 360)
//                    let targetAngle = round(normalizedAngle / sectorAngle) * sectorAngle
//                    self.rotationAngle = targetAngle
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
//                            self.showReward = true
//                        }
//                        
//                        onComplete(self.rewardPoints)
//                        
//                        self.isSpinning = false
//                        
//                        // Активируем блокировку на 24 часа
//                        self.activateLock()
//                    }
//                }
//            }
//        }
//    }
//    
//    // Активация 24-часовой блокировки
//    private func activateLock() {
//        // Сохраняем время последнего вращения
//        let now = Date()
//        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: userDefaultsLastSpinKey)
//        
//        isLocked = true
//        startLockTimer()
//    }
//    
//    // Запуск таймера для отсчета блокировки
//    private func startLockTimer() {
//        // Обновляем оставшееся время сразу
//        updateRemainingTime()
//        
//        // Запускаем таймер, который будет обновлять отображение каждый час
//        lockTimer?.invalidate()
//        lockTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
//            self?.updateRemainingTime()
//        }
//    }
//    
//    // Обновление оставшегося времени блокировки
//    private func updateRemainingTime() {
//        guard let lastSpinTimestamp = UserDefaults.standard.object(forKey: userDefaultsLastSpinKey) as? Double else {
//            isLocked = false
//            return
//        }
//        
//        let lastSpinDate = Date(timeIntervalSince1970: lastSpinTimestamp)
//        let now = Date()
//        
//        // Вычисляем время, прошедшее с момента последнего вращения
//        let timeElapsed = now.timeIntervalSince(lastSpinDate)
//        let totalLockTime: TimeInterval = 24 * 3600 // 24 часа в секундах
//        
//        if timeElapsed >= totalLockTime {
//            // Если прошло 24 часа, снимаем блокировку
//            isLocked = false
//            lockTimer?.invalidate()
//            lockTimer = nil
//        } else {
//            // Иначе обновляем оставшееся время
//            let timeRemaining = totalLockTime - timeElapsed
//            hoursRemaining = Int(ceil(timeRemaining / 3600)) // Округляем вверх до часа
//            
//            // Фиксируем статус блокировки
//            isLocked = true
//        }
//        
//        // Вызываем обновление UI в главном потоке
//        DispatchQueue.main.async {
//            self.objectWillChange.send()
//        }
//    }
//    
//    // Проверка статуса блокировки при запуске/появлении вью
//    func checkLockStatus() {
//        guard let lastSpinTimestamp = UserDefaults.standard.object(forKey: userDefaultsLastSpinKey) as? Double else {
//            isLocked = false
//            return
//        }
//        
//        let lastSpinDate = Date(timeIntervalSince1970: lastSpinTimestamp)
//        let now = Date()
//        let timeElapsed = now.timeIntervalSince(lastSpinDate)
//        
//        if timeElapsed < 24 * 3600 { // Меньше 24 часов
//            isLocked = true
//            startLockTimer()
//        } else {
//            // Прошло больше 24 часов, снимаем блокировку
//            isLocked = false
//        }
//    }
//    
//    // При уничтожении объекта останавливаем таймеры
//    deinit {
//        spinTimer?.invalidate()
//        lockTimer?.invalidate()
//    }
//}
//
//#Preview {
//    SpinReelView(appState: AppState())
//}

import SwiftUI

struct SpinReelView: View {
    @StateObject private var reelViewModel = ReelViewModel()
    @ObservedObject var appState: AppState
    
    #if DEBUG
    @State private var showDebugOptions = false
    #endif
    
    var body: some View {
        HStack(spacing: 10) {
            // MARK: - DEBUG
            #if DEBUG
            VStack {
                Button {
                    showDebugOptions.toggle()
                } label: {
                    Image(systemName: "ladybug")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if showDebugOptions {
                    VStack(spacing: 10) {
                        Button("Reset") {
                            reelViewModel.resetLockForDebug()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Set 1h timer") {
                            reelViewModel.setDebugTimer(hours: 1)
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            #endif
            // MARK: - endif
            
            if reelViewModel.showReward {
                Text("+\(reelViewModel.rewardPoints) points!")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 1)
                    .transition(.scale.combined(with: .opacity))
                    .padding(4)
                    .background(
                        Image(.topbarrectangle)
                            .resizable()
                            .clipShape(.rect(cornerRadius: 8))
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                reelViewModel.showReward = false
                            }
                        }
                    }
            }
            
            Button {
                SettingsManager.shared.getTapSound()
                if !reelViewModel.isSpinning && !reelViewModel.isLocked {
                    reelViewModel.spinReel(onComplete: { points in
                        appState.addScore(points: points)
                    })
                }
            } label: {
                ZStack {
                    Image(.reel)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                        .rotationEffect(.degrees(reelViewModel.rotationAngle))
                        .overlay {
                            Image(.arrow)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.9)
                        }
                    
                    if reelViewModel.showLockOverlay {
                        VStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.black)
                            
                            Text("\(reelViewModel.hoursRemaining)h")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .shadow(color: .black, radius: 2)
                        }
                        .transition(.opacity)
                    }
                }
            }
//            .background(.gray)
            .buttonStyle(.plain)
            .disabled(reelViewModel.isSpinning || reelViewModel.isLocked)
        }
//        .background(.brown)
        .onAppear {
            reelViewModel.checkLockStatus()
        }
    }
}

#Preview {
    SpinReelView(appState: AppState())
}
