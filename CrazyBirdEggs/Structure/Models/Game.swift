import Foundation

// MARK: - Enums

enum GamePlayer: String {
    case human = "Human"
    case ai = "AI"
}

enum GamePhase {
    case placement
    case attack
    case animation
    case gameOver
}

// MARK: - Анимационные состояния
enum BoxAnimationState {
    case normal
    case explosion
    case showChicken
    case destroyed
}

enum ArenaState {
    case empty
    case showingHumanChicken
    case showingAIChicken
    case gameOver
}

// MARK: - Models

// MARK: BoxModel
struct BoxModel: Identifiable, Equatable {
    let id = UUID()
    let row: Int
    let column: Int
    var containsPlayer: GamePlayer?
    var isDestroyed: Bool = false
    var showExplosion: Bool = false
    var showChicken: Bool = false
    
    static func == (lhs: BoxModel, rhs: BoxModel) -> Bool {
        lhs.id == rhs.id
    }
    
    var boxImageName: ImageResource {
        if showExplosion {
            return .boom
        } else if containsPlayer == .human && showChicken {
            return .inbox
        } else {
            return .box1
        }
    }
}

// MARK: PlayerModel
struct PlayerModel {
    var type: GamePlayer
    var currentRow: Int = 0
    var currentColumn: Int? = nil
    var hasReachedArena: Bool = false
    
    var position: (row: Int, column: Int)? {
        if let column = currentColumn {
            return (currentRow, column)
        }
        return nil
    }
}

// MARK: LevelModel
struct LevelModel: Identifiable {
    let id: Int
    let aiActions: [AIAction]
    
    struct AIAction {
        let placementColumn: Int
        let attackColumn: Int
    }
    
    // Генерирует случайные действия ИИ для уровня
    static func generateLevel(id: Int) -> LevelModel {
        // Количество рядов (0 - первый ряд из 5 коробок, 4 - центральная арена)
        let rowCount = 5
        var aiActions: [AIAction] = []
        
        // Создаем действия для каждого ряда
        for row in 0..<rowCount {
            let maxColumns = 5 - row
            // Случайный выбор колонки для размещения
            let placementColumn = Int.random(in: 0..<maxColumns)
            // Случайный выбор колонки для атаки
            let attackColumn = Int.random(in: 0..<maxColumns)
            
            aiActions.append(
                AIAction(
                    placementColumn: placementColumn,
                    attackColumn: attackColumn
                )
            )
        }
        
        return LevelModel(id: id, aiActions: aiActions)
    }
}

// MARK: AppState
// AppState хранит глобальное состояние приложения (прогресс)
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
