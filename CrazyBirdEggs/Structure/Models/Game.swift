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

// MARK: - Models

// MARK: BoxModel
struct BoxModel: Identifiable, Equatable {
    let id = UUID()
    let row: Int
    let column: Int
    var containsPlayer: GamePlayer?
    var isDestroyed: Bool = false
    
    static func == (lhs: BoxModel, rhs: BoxModel) -> Bool {
        lhs.id == rhs.id
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
class AppState: ObservableObject {
    @Published var unlockedLevels: Int = 1
    @Published var totalScore: Int = 0
    
    private let userDefaultsUnlockedLevelsKey = "unlockedLevels"
    private let userDefaultsTotalScoreKey = "totalScore"
    
    init() {
        loadProgress()
    }
    
    func unlockNextLevel() {
        if unlockedLevels < 10 {
            unlockedLevels += 1
            saveProgress()
        }
    }
    
    func addScore(points: Int) {
        totalScore += points
        saveProgress()
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(unlockedLevels, forKey: userDefaultsUnlockedLevelsKey)
        UserDefaults.standard.set(totalScore, forKey: userDefaultsTotalScoreKey)
    }
    
    private func loadProgress() {
        unlockedLevels = UserDefaults.standard.integer(forKey: userDefaultsUnlockedLevelsKey)
        if unlockedLevels == 0 { unlockedLevels = 1 } // Обеспечиваем, что хотя бы 1 уровень разблокирован
        
        totalScore = UserDefaults.standard.integer(forKey: userDefaultsTotalScoreKey)
    }
    
    func resetProgress() {
        unlockedLevels = 1
        totalScore = 0
        saveProgress()
    }
}
