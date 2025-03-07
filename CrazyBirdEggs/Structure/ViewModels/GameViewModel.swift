import Foundation

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
    @Published var gameMessage: String = "Select a box to place"
    
    // Свойства для отслеживания состояний анимации
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
        // Создаем игровое поле для обоих игроков
        createBoxes()
    }
    
    private func createBoxes() {
        humanBoxes = []
        aiBoxes = []
        
        // Создаем коробки для человека (левая пирамида)
        
        // 5 коробок в первом ряду
        var row0Human: [BoxModel] = []
        for i in 0..<5 {
            row0Human.append(BoxModel(row: 0, column: i))
        }
        humanBoxes.append(row0Human)
        
        // 4 коробки во втором ряду
        var row1Human: [BoxModel] = []
        for i in 0..<4 {
            row1Human.append(BoxModel(row: 1, column: i))
        }
        humanBoxes.append(row1Human)
        
        // 3 коробки в третьем ряду
        var row2Human: [BoxModel] = []
        for i in 0..<3 {
            row2Human.append(BoxModel(row: 2, column: i))
        }
        humanBoxes.append(row2Human)
        
        // 2 коробки в четвертом ряду
        var row3Human: [BoxModel] = []
        for i in 0..<2 {
            row3Human.append(BoxModel(row: 3, column: i))
        }
        humanBoxes.append(row3Human)
        
        // Создаем коробки для AI (правая пирамида)
        
        // 5 коробок в первом ряду
        var row0AI: [BoxModel] = []
        for i in 0..<5 {
            row0AI.append(BoxModel(row: 0, column: i))
        }
        aiBoxes.append(row0AI)
        
        // 4 коробки во втором ряду
        var row1AI: [BoxModel] = []
        for i in 0..<4 {
            row1AI.append(BoxModel(row: 1, column: i))
        }
        aiBoxes.append(row1AI)
        
        // 3 коробки в третьем ряду
        var row2AI: [BoxModel] = []
        for i in 0..<3 {
            row2AI.append(BoxModel(row: 2, column: i))
        }
        aiBoxes.append(row2AI)
        
        // 2 коробки в четвертом ряду
        var row3AI: [BoxModel] = []
        for i in 0..<2 {
            row3AI.append(BoxModel(row: 3, column: i))
        }
        aiBoxes.append(row3AI)
    }
    
    // MARK: - Game Logic
    
    // Обработка тапа по коробке для человеческого игрока
    func handleHumanBoxTap(row: Int, column: Int) {
        guard !animationInProgress && currentTurn == .human && currentPhase == .placement else { return }
        
        // Проверяем, может ли игрок разместить цыпленка в этом ряду
        if row != humanPlayer.currentRow {
            return
        }
        
        // Проверяем, что коробка пуста
        if humanBoxes[row][column].containsPlayer != nil {
            return
        }
        
        // Размещаем цыпленка
        placeHumanChicken(row: row, column: column)
        
        // Ход AI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.makeAIPlacementMove()
        }
    }
    
    // Обработка тапа по коробке AI для атаки
    func handleAIBoxTap(row: Int, column: Int) {
        guard !animationInProgress && currentTurn == .human && currentPhase == .attack else { return }
        
        // Проверяем, что атака происходит в ряду, где находится цыпленок AI
        if row != aiPlayer.currentRow {
            return
        }
        
        // Атакуем выбранную коробку
        attackAIBox(targetRow: row, targetColumn: column)
    }
    
    // Размещение цыпленка человека
    private func placeHumanChicken(row: Int, column: Int) {
        // Скрываем цыпленка в предыдущей коробке, если он был
        if let prevColumn = humanPlayer.currentColumn, humanPlayer.currentRow < humanBoxes.count {
            if prevColumn < humanBoxes[humanPlayer.currentRow].count {
                humanBoxes[humanPlayer.currentRow][prevColumn].containsPlayer = nil
                humanBoxes[humanPlayer.currentRow][prevColumn].boxState = .normal
            }
        }
        
        // Обновляем модель коробки
        humanBoxes[row][column].containsPlayer = .human
        // Используем новое состояние для коробки с цыпленком
        humanBoxes[row][column].boxState = .withChicken
        
        // Обновляем модель игрока
        humanPlayer.currentColumn = column
        currentTurn = .ai
    }
    
    // Ход AI в фазе размещения
    private func makeAIPlacementMove() {
        guard currentPhase == .placement else {
            return
        }
        
        // Проверяем, не вышли ли мы за пределы рядов
        guard aiPlayer.currentRow < aiBoxes.count else {
            // Если AI достиг конца, он выиграл
            handleAIWin()
            return
        }
        
        // Если у нас закончились заготовленные ходы AI, генерируем случайный
        if aiActionIndex >= currentLevel.aiActions.count {
            let row = aiPlayer.currentRow
            let maxCol = aiBoxes[row].count - 1
            let column = Int.random(in: 0...maxCol)
            
            // Размещаем цыпленка AI
            aiBoxes[row][column].containsPlayer = .ai
            aiBoxes[row][column].boxState = .normal  // Не показываем ни коробку с цыпленком, ни цыпленка
            aiPlayer.currentColumn = column
        } else {
            let action = currentLevel.aiActions[aiActionIndex]
            let row = aiPlayer.currentRow
            let column = min(action.placementColumn, aiBoxes[row].count - 1)
            
            // Размещаем цыпленка AI
            aiBoxes[row][column].containsPlayer = .ai
            aiBoxes[row][column].boxState = .normal  // Не показываем ни коробку с цыпленком, ни цыпленка
            aiPlayer.currentColumn = column
        }
        
        // Переходим к фазе атаки
        currentPhase = .attack
        currentTurn = .human
        gameMessage = "Select a box to attack"
    }
    
    // Атака на коробку AI
    private func attackAIBox(targetRow: Int, targetColumn: Int) {
        // Проверяем валидность индексов
        guard targetRow < aiBoxes.count && targetColumn < aiBoxes[targetRow].count else {
            print("Invalid attack indices: row \(targetRow), column \(targetColumn)")
            return
        }
        
        animationInProgress = true
        
        // Начинаем анимацию
        currentPhase = .animation
        
        // 1. Анимация взрыва - показать взрыв на 0.5 секунды
        aiBoxes[targetRow][targetColumn].boxState = .explosion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Проверяем, содержит ли атакованная коробка цыпленка противника
            let hitOpponent = self.aiBoxes[targetRow][targetColumn].containsPlayer == .ai
            
            if hitOpponent {
                // 2. Показываем только цыпленка на 0.5 секунды
                self.aiBoxes[targetRow][targetColumn].boxState = .onlyChicken
                self.gameMessage = "You hit!!"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    
                    // 3. Сбрасываем состояние и возвращаем цыпленка на начальную позицию
                    self.resetPlayerPosition(player: .ai)
                    
                    // 4. Восстанавливаем только коробки AI, так как мы попали в цыпленка AI
                    self.resetAIDestroyedBoxes()
                    
                    // Ход AI для атаки
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        guard let self = self else { return }
                        self.makeAIAttackMove()
                    }
                }
            } else {
                // Не попали - отмечаем коробку как уничтоженную
                self.aiBoxes[targetRow][targetColumn].isDestroyed = true
                self.aiBoxes[targetRow][targetColumn].boxState = .destroyed
                self.gameMessage = "Miss.."
                
                // Ход AI для атаки
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.makeAIAttackMove()
                }
            }
        }
    }
    
    // Ход AI в фазе атаки
    private func makeAIAttackMove() {
        guard aiActionIndex < currentLevel.aiActions.count else {
            // Если у нас закончились заготовленные ходы AI, генерируем случайный
            let targetRow = humanPlayer.currentRow
            guard targetRow < humanBoxes.count else {
                print("Invalid AI attack row: \(targetRow)")
                moveToNextTurn()
                return
            }
            
            let maxCol = humanBoxes[targetRow].count - 1
            let targetColumn = Int.random(in: 0...maxCol)
            performAIAttack(targetRow: targetRow, targetColumn: targetColumn)
            return
        }
        
        let action = currentLevel.aiActions[aiActionIndex]
        let targetRow = humanPlayer.currentRow
        
        // Проверка валидности индексов
        guard targetRow < humanBoxes.count else {
            print("Invalid AI attack row: \(targetRow)")
            moveToNextTurn()
            return
        }
        
        let targetColumn = min(action.attackColumn, humanBoxes[targetRow].count - 1)
        performAIAttack(targetRow: targetRow, targetColumn: targetColumn)
    }
    
    // Выполнение атаки AI
    private func performAIAttack(targetRow: Int, targetColumn: Int) {
        // Показываем анимацию атаки AI
        gameMessage = "AI attack!"
        
        // 1. Анимация взрыва - показать взрыв на 0.5 секунды
        humanBoxes[targetRow][targetColumn].boxState = .explosion
        
        // Через задержку проверяем результат атаки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Проверяем, содержит ли атакованная коробка цыпленка игрока
            let hitPlayer = self.humanBoxes[targetRow][targetColumn].containsPlayer == .human
            
            if hitPlayer {
                // 2. Показываем только цыпленка на 0.5 секунды
                self.humanBoxes[targetRow][targetColumn].boxState = .onlyChicken
                self.gameMessage = "AI hit your chicken!"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    
                    // 3. Сбрасываем состояние и возвращаем цыпленка на начальную позицию
                    self.resetPlayerPosition(player: .human)
                    
                    // 4. Восстанавливаем только коробки человека, так как AI попал в цыпленка человека
                    self.resetHumanDestroyedBoxes()
                    
                    // Переходим к следующему ходу
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        guard let self = self else { return }
                        self.moveToNextTurn()
                    }
                }
            } else {
                // Не попали - отмечаем коробку как уничтоженную
                self.humanBoxes[targetRow][targetColumn].isDestroyed = true
                self.humanBoxes[targetRow][targetColumn].boxState = .destroyed
                self.gameMessage = "AI miss.."
                
                // Переходим к следующему ходу
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.moveToNextTurn()
                }
            }
        }
    }
    
    // Сброс коробок человеческого игрока
    private func resetHumanDestroyedBoxes() {
        // Восстанавливаем только коробки для человека
        for i in 0..<humanBoxes.count {
            for j in 0..<humanBoxes[i].count {
                if humanBoxes[i][j].boxState == .destroyed {
                    humanBoxes[i][j].boxState = .normal
                    humanBoxes[i][j].isDestroyed = false
                }
            }
        }
    }

    // Сброс коробок AI
    private func resetAIDestroyedBoxes() {
        // Восстанавливаем только коробки для AI
        for i in 0..<aiBoxes.count {
            for j in 0..<aiBoxes[i].count {
                if aiBoxes[i][j].boxState == .destroyed {
                    aiBoxes[i][j].boxState = .normal
                    aiBoxes[i][j].isDestroyed = false
                }
            }
        }
    }
    
    // Сброс всех уничтоженных коробок
    private func resetAllDestroyedBoxes() {
        // Восстанавливаем все уничтоженные коробки для человека
        for i in 0..<humanBoxes.count {
            for j in 0..<humanBoxes[i].count {
                if humanBoxes[i][j].boxState == .destroyed {
                    humanBoxes[i][j].boxState = .normal
                    humanBoxes[i][j].isDestroyed = false
                }
            }
        }
        
        // Восстанавливаем все уничтоженные коробки для AI
        for i in 0..<aiBoxes.count {
            for j in 0..<aiBoxes[i].count {
                if aiBoxes[i][j].boxState == .destroyed {
                    aiBoxes[i][j].boxState = .normal
                    aiBoxes[i][j].isDestroyed = false
                }
            }
        }
    }
    
    // Сброс позиции игрока на начальную
    private func resetPlayerPosition(player: GamePlayer) {
        if player == .human {
            // Находим текущую коробку и очищаем ее
            if let column = humanPlayer.currentColumn {
                if humanPlayer.currentRow < humanBoxes.count && column < humanBoxes[humanPlayer.currentRow].count {
                    // Очищаем информацию о наличии игрока в коробке
                    humanBoxes[humanPlayer.currentRow][column].containsPlayer = nil
                    humanBoxes[humanPlayer.currentRow][column].boxState = .normal
                }
            }
            
            // Сбрасываем позицию игрока
            humanPlayer.currentRow = 0
            humanPlayer.currentColumn = nil
        } else {
            // Находим текущую коробку AI и очищаем ее
            if let column = aiPlayer.currentColumn {
                if aiPlayer.currentRow < aiBoxes.count && column < aiBoxes[aiPlayer.currentRow].count {
                    // Очищаем информацию о наличии AI в коробке
                    aiBoxes[aiPlayer.currentRow][column].containsPlayer = nil
                    aiBoxes[aiPlayer.currentRow][column].boxState = .normal
                }
            }
            
            // Сбрасываем позицию AI
            aiPlayer.currentRow = 0
            aiPlayer.currentColumn = nil
        }
    }
    
    // Перемещение игроков на следующий ряд
    private func movePlayersToNextRow() {
        // Очищаем текущие позиции
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
        
        // Увеличиваем индекс ряда
        humanPlayer.currentRow += 1
        aiPlayer.currentRow += 1
        
        // Проверяем, не выиграл ли кто-то (достиг центральной арены)
        if humanPlayer.currentRow >= 4 {
            handleHumanWin()
            return
        }
        
        if aiPlayer.currentRow >= 4 {
            handleAIWin()
            return
        }
        
        // Сбрасываем колонки
        humanPlayer.currentColumn = nil
        aiPlayer.currentColumn = nil
        
        // Увеличиваем индекс действий AI
        aiActionIndex += 1
        
        // Переходим к фазе размещения
        currentPhase = .placement
        currentTurn = .human
        gameMessage = "Select a box to place"
    }
    
    // Переход к следующему ходу
    private func moveToNextTurn() {
        animationInProgress = false
        
        // Если AI был сбит, а человек нет
        if aiPlayer.currentColumn == nil && humanPlayer.currentColumn != nil {
            // Перемещаем человека на следующий ряд
            moveHumanPlayerToNextRow()
            
            // Проверяем, не достиг ли человек центральной арены
            if humanPlayer.currentRow >= 4 {
                handleHumanWin()
                return
            }
            
            // Переходим к фазе размещения для человека (сначала размещение, затем атака)
            currentPhase = .placement
            currentTurn = .human
            gameMessage = "Select a box to place"
            return
        }
        
        // Если человек был сбит, а AI нет
        if humanPlayer.currentColumn == nil && aiPlayer.currentColumn != nil {
            // Перемещаем AI на следующий ряд
            moveAIPlayerToNextRow()
            
            // Проверяем, не достиг ли AI центральной арены
            if aiPlayer.currentRow >= 4 {
                handleAIWin()
                return
            }
            
            // Переходим к фазе размещения для человека
            currentPhase = .placement
            currentTurn = .human
            gameMessage = "Select a box to place"
            return
        }
        
        // Если оба игрока не были сбиты, они оба перемещаются вперед
        if humanPlayer.currentColumn != nil && aiPlayer.currentColumn != nil {
            movePlayersToNextRow()
            
            // Проверяем условие победы после перемещения
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
        
        // Если оба были сбиты (маловероятный сценарий, но на всякий случай)
        currentPhase = .placement
        currentTurn = .human
        gameMessage = "Select a box to place"
    }
    
    // Перемещение только человеческого игрока на следующий ряд
    private func moveHumanPlayerToNextRow() {
        // Очищаем текущую позицию
        if let column = humanPlayer.currentColumn {
            if humanPlayer.currentRow < humanBoxes.count && column < humanBoxes[humanPlayer.currentRow].count {
                humanBoxes[humanPlayer.currentRow][column].containsPlayer = nil
                humanBoxes[humanPlayer.currentRow][column].boxState = .normal
            }
        }
        
        // Увеличиваем индекс ряда
        humanPlayer.currentRow += 1
        
        // Сбрасываем колонку
        humanPlayer.currentColumn = nil
    }
    
    // Перемещение только AI на следующий ряд
    private func moveAIPlayerToNextRow() {
        // Очищаем текущую позицию
        if let column = aiPlayer.currentColumn {
            if aiPlayer.currentRow < aiBoxes.count && column < aiBoxes[aiPlayer.currentRow].count {
                aiBoxes[aiPlayer.currentRow][column].containsPlayer = nil
                aiBoxes[aiPlayer.currentRow][column].boxState = .normal
            }
        }
        
        // Увеличиваем индекс ряда
        aiPlayer.currentRow += 1
        
        // Сбрасываем колонку
        aiPlayer.currentColumn = nil
    }
    
    // Перемещение игроков на следующий ряд
    private func handleHumanWin() {
        // Показываем цыпленка в центральной арене на 0.5 секунды
        showingCentralArenaChicken = true
        arenaState = .showingHumanChicken
        
        // Восстанавливаем все коробки перед показом экрана победы
        resetHumanDestroyedBoxes()
        resetAIDestroyedBoxes()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Скрываем цыпленка и показываем оверлей победы
            self.showingCentralArenaChicken = false
            self.arenaState = .gameOver
            self.currentPhase = .gameOver
            self.showVictoryOverlay = true
            
            // Отмечаем уровень как пройденный и разблокируем следующий
            self.appState.completeLevel(levelId: self.currentLevel.id)
        }
    }
    
    // Обработка победы AI
    private func handleAIWin() {
        // Показываем цыпленка AI в центральной арене на 0.5 секунды
        showingCentralArenaChicken = true
        arenaState = .showingAIChicken
        
        // Восстанавливаем все коробки перед показом экрана поражения
        resetHumanDestroyedBoxes()
        resetAIDestroyedBoxes()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Скрываем цыпленка и показываем оверлей поражения
            self.showingCentralArenaChicken = false
            self.arenaState = .gameOver
            self.currentPhase = .gameOver
            self.showDefeatOverlay = true
        }
    }
    
    // Перезапуск уровня
    func restartLevel() {
        aiActionIndex = 0
        currentPhase = .placement
        currentTurn = .human
        showVictoryOverlay = false
        showDefeatOverlay = false
        humanPlayer = PlayerModel(type: .human)
        aiPlayer = PlayerModel(type: .ai)
        gameMessage = "Select a box to place"
        arenaState = .empty
        showingCentralArenaChicken = false
        
        // Пересоздаем игровое поле
        createBoxes()
        
        // Сбрасываем анимационный флаг
        animationInProgress = false
    }
    
    // Проверка, нужно ли подсвечивать ряд human коробок
    func shouldHighlightHumanRow(row: Int) -> Bool {
        if currentPhase == .placement && currentTurn == .human {
            return row == humanPlayer.currentRow
        }
        return false
    }
    
    // Проверка, нужно ли подсвечивать ряд AI коробок
    func shouldHighlightAIRow(row: Int) -> Bool {
        if currentPhase == .attack && currentTurn == .human {
            return row == aiPlayer.currentRow
        }
        return false
    }
}
