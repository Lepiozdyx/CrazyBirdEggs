import Foundation

class AppState: ObservableObject {
    @Published var unlockedLevels: Int = 1
    @Published var completedLevels: Set<Int> = []
    @Published var totalScore: Int = 0
    
    private let userDefaultsUnlockedLevelsKey = "unlockedLevels"
    private let userDefaultsCompletedLevelsKey = "completedLevels"
    private let userDefaultsTotalScoreKey = "totalScore"
    
    init() {
        loadProgress()
    }
    
    func spend(_ amount: Int) -> Bool {
        guard totalScore >= amount else { return false }
        totalScore -= amount
        return true
    }
    
    func completeLevel(levelId: Int) {
        completedLevels.insert(levelId)
        if levelId == unlockedLevels && unlockedLevels < 10 {
            unlockedLevels = levelId + 1
        }
        addScore(points: 100)
        saveProgress()
    }
    
    func isLevelCompleted(levelId: Int) -> Bool {
        return completedLevels.contains(levelId)
    }
    
    func addScore(points: Int) {
        totalScore += points
        saveProgress()
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(unlockedLevels, forKey: userDefaultsUnlockedLevelsKey)
        
        let completedLevelsArray = Array(completedLevels)
        UserDefaults.standard.set(completedLevelsArray, forKey: userDefaultsCompletedLevelsKey)
        
        UserDefaults.standard.set(totalScore, forKey: userDefaultsTotalScoreKey)
    }
    
    private func loadProgress() {
        unlockedLevels = UserDefaults.standard.integer(forKey: userDefaultsUnlockedLevelsKey)
        if unlockedLevels == 0 { unlockedLevels = 1 } // Обеспечиваем, что хотя бы 1 уровень разблокирован
        
        if let completedLevelsArray = UserDefaults.standard.array(forKey: userDefaultsCompletedLevelsKey) as? [Int] {
            completedLevels = Set(completedLevelsArray)
        }
        
        totalScore = UserDefaults.standard.integer(forKey: userDefaultsTotalScoreKey)
    }
    
    func resetProgress() {
        unlockedLevels = 1
        completedLevels = []
        totalScore = 0
        saveProgress()
    }
}
