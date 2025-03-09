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

enum BoxState {
    case normal
    case withChicken
    case explosion
    case onlyChicken
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
    var boxState: BoxState = .normal
    
    static func == (lhs: BoxModel, rhs: BoxModel) -> Bool {
        lhs.id == rhs.id
    }
    
    var boxImageName: ImageResource? {
        switch boxState {
        case .normal:
            return .box1
        case .withChicken:
            return .inbox
        case .explosion:
            return .boom
        case .onlyChicken:
            return nil  // Не показываем коробку, только цыпленок
        case .destroyed:
            return nil  // Коробка уничтожена, ничего не показываем
        }
    }
    
    // Определяет, нужно ли показывать цыпленка
    var shouldShowChicken: Bool {
        return containsPlayer != nil && boxState == .onlyChicken
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

// MARK: Player skin model
struct HeroSkin: Identifiable {
    let id: Int
    let image: ImageResource
    let price: Int
}
