import Foundation

enum AnimationDelay {
    static let aiTurn: TimeInterval = 0.5
    static let explosion: TimeInterval = 0.6
    static let chickenReveal: TimeInterval = 0.8
    static let nextTurn: TimeInterval = 0.5
    static let arenaChicken: TimeInterval = 0.8
}

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentLevel: LevelModel
    @Published var humanBoxes: [[BoxModel]] = []
    @Published var aiBoxes: [[BoxModel]] = []
    @Published var humanPlayer: PlayerModel
    @Published var aiPlayer: PlayerModel
    @Published var currentPhase: GamePhase = .placement
    @Published var currentTurn: GamePlayer = .human
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    @Published var gameMessage: String = "Select a box"
    
    @Published var arenaState: ArenaState = .empty
    @Published var showingCentralArenaChicken: Bool = false
    @Published var targetBox: BoxModel? = nil
    
    // MARK: - Private Properties
    
    private var appState: AppState
    private var aiActionIndex: Int = 0
    private var animationInProgress: Bool = false
    
    // MARK: - Init
    
    init(levelId: Int, appState: AppState) {
        self.appState = appState
        self.currentLevel = LevelModel.generateLevel(id: levelId)
        self.humanPlayer = PlayerModel(type: .human)
        self.aiPlayer = PlayerModel(type: .ai)
        
        setupGame()
    }
    
    // MARK: - Game Setup
    
    private func setupGame() {
        createBoxes()
    }
    
    private func createBoxes() {
        humanBoxes = []
        aiBoxes = []
        
        var row0Human: [BoxModel] = []
        for i in 0..<5 {
            row0Human.append(BoxModel(row: 0, column: i))
        }
        humanBoxes.append(row0Human)
        
        var row1Human: [BoxModel] = []
        for i in 0..<4 {
            row1Human.append(BoxModel(row: 1, column: i))
        }
        humanBoxes.append(row1Human)
        
        var row2Human: [BoxModel] = []
        for i in 0..<3 {
            row2Human.append(BoxModel(row: 2, column: i))
        }
        humanBoxes.append(row2Human)
        
        var row3Human: [BoxModel] = []
        for i in 0..<2 {
            row3Human.append(BoxModel(row: 3, column: i))
        }
        humanBoxes.append(row3Human)
        
        // ai
        var row0AI: [BoxModel] = []
        for i in 0..<5 {
            row0AI.append(BoxModel(row: 0, column: i))
        }
        aiBoxes.append(row0AI)
        
        var row1AI: [BoxModel] = []
        for i in 0..<4 {
            row1AI.append(BoxModel(row: 1, column: i))
        }
        aiBoxes.append(row1AI)
        
        var row2AI: [BoxModel] = []
        for i in 0..<3 {
            row2AI.append(BoxModel(row: 2, column: i))
        }
        aiBoxes.append(row2AI)
        
        var row3AI: [BoxModel] = []
        for i in 0..<2 {
            row3AI.append(BoxModel(row: 3, column: i))
        }
        aiBoxes.append(row3AI)
    }
    
    // MARK: - Game Logic
    
    func handleHumanBoxTap(row: Int, column: Int) {
        guard !animationInProgress && currentTurn == .human && currentPhase == .placement else { return }
        
        if row != humanPlayer.currentRow {
            return
        }
        
        if humanBoxes[row][column].containsPlayer != nil {
            return
        }
        
        placeHumanChicken(row: row, column: column)
        
        // ai
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.aiTurn) { [weak self] in
            guard let self = self else { return }
            self.makeAIPlacementMove()
        }
    }
    
    func handleAIBoxTap(row: Int, column: Int) {
        guard !animationInProgress && currentTurn == .human && currentPhase == .attack else { return }
        
        if row != aiPlayer.currentRow {
            return
        }
        
        attackAIBox(targetRow: row, targetColumn: column)
    }
    
    private func placeHumanChicken(row: Int, column: Int) {
        if let prevColumn = humanPlayer.currentColumn, humanPlayer.currentRow < humanBoxes.count {
            if prevColumn < humanBoxes[humanPlayer.currentRow].count {
                humanBoxes[humanPlayer.currentRow][prevColumn].containsPlayer = nil
                humanBoxes[humanPlayer.currentRow][prevColumn].boxState = .normal
            }
        }
        
        humanBoxes[row][column].containsPlayer = .human
        humanBoxes[row][column].boxState = .withChicken
        
        humanPlayer.currentColumn = column
        currentTurn = .ai
    }
    
    private func makeAIPlacementMove() {
        guard currentPhase == .placement else {
            return
        }
        
        guard aiPlayer.currentRow < aiBoxes.count else {
            handleAIWin()
            return
        }

        let row = aiPlayer.currentRow
        let maxCol = aiBoxes[row].count - 1
        let column = Int.random(in: 0...maxCol)
        
        aiBoxes[row][column].containsPlayer = .ai
        aiBoxes[row][column].boxState = .normal
        aiPlayer.currentColumn = column
        
        currentPhase = .attack
        currentTurn = .human
        gameMessage = "Select a box to attack"
    }
    
    private func attackAIBox(targetRow: Int, targetColumn: Int) {
        guard targetRow < aiBoxes.count && targetColumn < aiBoxes[targetRow].count else {
            print("Invalid attack indices: row \(targetRow), column \(targetColumn)")
            return
        }
        
        animationInProgress = true
        
        currentPhase = .animation
        
        aiBoxes[targetRow][targetColumn].boxState = .explosion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.explosion) { [weak self] in
            guard let self = self else { return }
            
            let hitOpponent = self.aiBoxes[targetRow][targetColumn].containsPlayer == .ai
            
            if hitOpponent {
                self.aiBoxes[targetRow][targetColumn].boxState = .onlyChicken
                self.gameMessage = "You hit!!"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.chickenReveal) { [weak self] in
                    guard let self = self else { return }
                    
                    self.resetPlayerPosition(player: .ai)
                    self.resetAIDestroyedBoxes()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.nextTurn) { [weak self] in
                        guard let self = self else { return }
                        self.makeAIAttackMove()
                    }
                }
            } else {
                self.aiBoxes[targetRow][targetColumn].isDestroyed = true
                self.aiBoxes[targetRow][targetColumn].boxState = .destroyed
                self.gameMessage = "Miss.."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.nextTurn) { [weak self] in
                    guard let self = self else { return }
                    self.makeAIAttackMove()
                }
            }
        }
    }
    
    private func makeAIAttackMove() {
        let targetRow = humanPlayer.currentRow
        
        guard targetRow < humanBoxes.count else {
            print("Invalid AI attack row: \(targetRow)")
            moveToNextTurn()
            return
        }
        
        let maxCol = humanBoxes[targetRow].count - 1
        let targetColumn = Int.random(in: 0...maxCol)
        
        performAIAttack(targetRow: targetRow, targetColumn: targetColumn)
    }
    
    private func performAIAttack(targetRow: Int, targetColumn: Int) {
        gameMessage = "AI attack!"
        
        humanBoxes[targetRow][targetColumn].boxState = .explosion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.explosion) { [weak self] in
            guard let self = self else { return }
            
            let hitPlayer = self.humanBoxes[targetRow][targetColumn].containsPlayer == .human
            
            if hitPlayer {
                self.humanBoxes[targetRow][targetColumn].boxState = .onlyChicken
                self.gameMessage = "AI hit your chicken!"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.chickenReveal) { [weak self] in
                    guard let self = self else { return }
                    
                    self.resetPlayerPosition(player: .human)
                    self.resetHumanDestroyedBoxes()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.nextTurn) { [weak self] in
                        guard let self = self else { return }
                        self.moveToNextTurn()
                    }
                }
            } else {
                self.humanBoxes[targetRow][targetColumn].isDestroyed = true
                self.humanBoxes[targetRow][targetColumn].boxState = .destroyed
                self.gameMessage = "AI miss.."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.nextTurn) { [weak self] in
                    guard let self = self else { return }
                    self.moveToNextTurn()
                }
            }
        }
    }
    
    private func resetHumanDestroyedBoxes() {
        for i in 0..<humanBoxes.count {
            for j in 0..<humanBoxes[i].count {
                if humanBoxes[i][j].boxState == .destroyed {
                    humanBoxes[i][j].boxState = .normal
                    humanBoxes[i][j].isDestroyed = false
                }
            }
        }
    }

    private func resetAIDestroyedBoxes() {
        for i in 0..<aiBoxes.count {
            for j in 0..<aiBoxes[i].count {
                if aiBoxes[i][j].boxState == .destroyed {
                    aiBoxes[i][j].boxState = .normal
                    aiBoxes[i][j].isDestroyed = false
                }
            }
        }
    }
    
    private func resetAllDestroyedBoxes() {
        for i in 0..<humanBoxes.count {
            for j in 0..<humanBoxes[i].count {
                if humanBoxes[i][j].boxState == .destroyed {
                    humanBoxes[i][j].boxState = .normal
                    humanBoxes[i][j].isDestroyed = false
                }
            }
        }
        
        for i in 0..<aiBoxes.count {
            for j in 0..<aiBoxes[i].count {
                if aiBoxes[i][j].boxState == .destroyed {
                    aiBoxes[i][j].boxState = .normal
                    aiBoxes[i][j].isDestroyed = false
                }
            }
        }
    }
    
    private func resetPlayerPosition(player: GamePlayer) {
        if player == .human {
            if let column = humanPlayer.currentColumn {
                if humanPlayer.currentRow < humanBoxes.count && column < humanBoxes[humanPlayer.currentRow].count {
                    humanBoxes[humanPlayer.currentRow][column].containsPlayer = nil
                    humanBoxes[humanPlayer.currentRow][column].boxState = .normal
                }
            }
            
            humanPlayer.currentRow = 0
            humanPlayer.currentColumn = nil
        } else {
            if let column = aiPlayer.currentColumn {
                if aiPlayer.currentRow < aiBoxes.count && column < aiBoxes[aiPlayer.currentRow].count {
                    aiBoxes[aiPlayer.currentRow][column].containsPlayer = nil
                    aiBoxes[aiPlayer.currentRow][column].boxState = .normal
                }
            }
            
            aiPlayer.currentRow = 0
            aiPlayer.currentColumn = nil
            
            aiActionIndex = 0
        }
    }
    
    private func movePlayersToNextRow() {
        if let column = humanPlayer.currentColumn {
            if humanPlayer.currentRow < humanBoxes.count && column < humanBoxes[humanPlayer.currentRow].count {
                humanBoxes[humanPlayer.currentRow][column].containsPlayer = nil
                humanBoxes[humanPlayer.currentRow][column].boxState = .normal
            }
        }
        
        if let column = aiPlayer.currentColumn {
            if aiPlayer.currentRow < aiBoxes.count && column < aiBoxes[aiPlayer.currentRow].count {
                aiBoxes[aiPlayer.currentRow][column].containsPlayer = nil
                aiBoxes[aiPlayer.currentRow][column].boxState = .normal
            }
        }
        
        humanPlayer.currentRow += 1
        aiPlayer.currentRow += 1
        
        if humanPlayer.currentRow >= 4 {
            handleHumanWin()
            return
        }
        
        if aiPlayer.currentRow >= 4 {
            handleAIWin()
            return
        }
        
        humanPlayer.currentColumn = nil
        aiPlayer.currentColumn = nil
        
        currentPhase = .placement
        currentTurn = .human
        gameMessage = "Select a box"
    }
    
    private func moveToNextTurn() {
        animationInProgress = false
        
        if aiPlayer.currentColumn == nil && humanPlayer.currentColumn != nil {
            moveHumanPlayerToNextRow()
            
            if humanPlayer.currentRow >= 4 {
                handleHumanWin()
                return
            }
            
            currentPhase = .placement
            currentTurn = .human
            gameMessage = "Select a box"
            return
        }
        
        if humanPlayer.currentColumn == nil && aiPlayer.currentColumn != nil {
            moveAIPlayerToNextRow()
            
            if aiPlayer.currentRow >= 4 {
                handleAIWin()
                return
            }
            
            currentPhase = .placement
            currentTurn = .human
            gameMessage = "Select a box"
            return
        }
        
        if humanPlayer.currentColumn != nil && aiPlayer.currentColumn != nil {
            movePlayersToNextRow()
            
            if humanPlayer.currentRow >= 4 {
                handleHumanWin()
                return
            }
            
            if aiPlayer.currentRow >= 4 {
                handleAIWin()
                return
            }
            
            return
        }
        
        currentPhase = .placement
        currentTurn = .human
        gameMessage = "Select a box"
    }
    
    private func moveHumanPlayerToNextRow() {
        if let column = humanPlayer.currentColumn {
            if humanPlayer.currentRow < humanBoxes.count && column < humanBoxes[humanPlayer.currentRow].count {
                humanBoxes[humanPlayer.currentRow][column].containsPlayer = nil
                humanBoxes[humanPlayer.currentRow][column].boxState = .normal
            }
        }
        
        humanPlayer.currentRow += 1
        humanPlayer.currentColumn = nil
    }
    
    private func moveAIPlayerToNextRow() {
        if let column = aiPlayer.currentColumn {
            if aiPlayer.currentRow < aiBoxes.count && column < aiBoxes[aiPlayer.currentRow].count {
                aiBoxes[aiPlayer.currentRow][column].containsPlayer = nil
                aiBoxes[aiPlayer.currentRow][column].boxState = .normal
            }
        }
        
        aiPlayer.currentRow += 1
        aiPlayer.currentColumn = nil
    }
    
    private func handleHumanWin() {
        showingCentralArenaChicken = true
        arenaState = .showingHumanChicken
        
        resetHumanDestroyedBoxes()
        resetAIDestroyedBoxes()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.arenaChicken) { [weak self] in
            guard let self = self else { return }
            
            self.showingCentralArenaChicken = false
            self.arenaState = .gameOver
            self.currentPhase = .gameOver
            self.showVictoryOverlay = true

            self.appState.completeLevel(levelId: self.currentLevel.id)
        }
    }
    
    private func handleAIWin() {
        showingCentralArenaChicken = true
        arenaState = .showingAIChicken
        
        resetHumanDestroyedBoxes()
        resetAIDestroyedBoxes()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDelay.arenaChicken) { [weak self] in
            guard let self = self else { return }
            
            self.showingCentralArenaChicken = false
            self.arenaState = .gameOver
            self.currentPhase = .gameOver
            self.showDefeatOverlay = true
        }
    }
    
    func restartLevel() {
        aiActionIndex = 0
        currentPhase = .placement
        currentTurn = .human
        showVictoryOverlay = false
        showDefeatOverlay = false
        humanPlayer = PlayerModel(type: .human)
        aiPlayer = PlayerModel(type: .ai)
        gameMessage = "Select a box"
        arenaState = .empty
        showingCentralArenaChicken = false
        
        createBoxes()
        
        animationInProgress = false
    }
    
    func shouldHighlightHumanRow(row: Int) -> Bool {
        if currentPhase == .placement && currentTurn == .human {
            return row == humanPlayer.currentRow
        }
        return false
    }
    
    func shouldHighlightAIRow(row: Int) -> Bool {
        if currentPhase == .attack && currentTurn == .human {
            return row == aiPlayer.currentRow
        }
        return false
    }
}
