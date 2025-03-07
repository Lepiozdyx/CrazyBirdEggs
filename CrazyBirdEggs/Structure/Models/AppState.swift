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
    
    // Отметить уровень как пройденный и разблокировать следующий
    func completeLevel(levelId: Int) {
        // Добавляем уровень в список пройденных
        completedLevels.insert(levelId)
        
        // Если этот уровень уже был максимальным разблокированным, разблокируем следующий
        if levelId == unlockedLevels && unlockedLevels < 10 {
            unlockedLevels = levelId + 1
        }
        
        // Добавляем очки
        addScore(points: 100)
        
        saveProgress()
    }
    
    // Проверяем, пройден ли уровень
    func isLevelCompleted(levelId: Int) -> Bool {
        return completedLevels.contains(levelId)
    }
    
    // Добавляем очки
    func addScore(points: Int) {
        totalScore += points
        saveProgress()
    }
    
    // Сохраняем прогресс
    private func saveProgress() {
        UserDefaults.standard.set(unlockedLevels, forKey: userDefaultsUnlockedLevelsKey)
        
        // Сохраняем пройденные уровни как массив
        let completedLevelsArray = Array(completedLevels)
        UserDefaults.standard.set(completedLevelsArray, forKey: userDefaultsCompletedLevelsKey)
        
        UserDefaults.standard.set(totalScore, forKey: userDefaultsTotalScoreKey)
    }
    
    // Загружаем прогресс
    private func loadProgress() {
        unlockedLevels = UserDefaults.standard.integer(forKey: userDefaultsUnlockedLevelsKey)
        if unlockedLevels == 0 { unlockedLevels = 1 } // Обеспечиваем, что хотя бы 1 уровень разблокирован
        
        // Загружаем пройденные уровни
        if let completedLevelsArray = UserDefaults.standard.array(forKey: userDefaultsCompletedLevelsKey) as? [Int] {
            completedLevels = Set(completedLevelsArray)
        }
        
        totalScore = UserDefaults.standard.integer(forKey: userDefaultsTotalScoreKey)
    }
    
    // Сбросить прогресс
    func resetProgress() {
        unlockedLevels = 1
        completedLevels = []
        totalScore = 0
        saveProgress()
    }
}
