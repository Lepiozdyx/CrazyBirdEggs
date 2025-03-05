import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPauseOverlay: Bool = false
    
    init(levelId: Int, appState: AppState) {
        _viewModel = StateObject(wrappedValue: GameViewModel(levelId: levelId, appState: appState))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фон
                Color.gray.opacity(0.2).ignoresSafeArea()
                
                // Игровое поле
                VStack {
                    // Верхняя панель
                    HStack {
                        // Кнопка паузы
                        Button {
                            showPauseOverlay = true
                        } label: {
                            Image(systemName: "pause.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Сообщение об игровой фазе
                        Text(viewModel.gameMessage)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Уровень
                        Text("Уровень \(viewModel.currentLevel.id)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Игровое поле с двумя пирамидами коробок и центральной ареной
                    HStack(spacing: 10) {
                        // Пирамида для человека (слева)
                        HumanBoardView(
                            viewModel: viewModel,
                            geometry: geometry
                        )
                        
                        // Центральная арена
                        CentralArenaView()
                            .frame(width: 80, height: 80)
                        
                        // Пирамида для AI (справа)
                        AIBoardView(
                            viewModel: viewModel,
                            geometry: geometry
                        )
                    }
                    
                    Spacer()
                }
                
                // Анимации
                if viewModel.showEgg {
                    EggView()
                        .position(viewModel.eggPosition ?? CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                }
                
                if viewModel.showExplosion {
                    ExplosionView()
                        .position(viewModel.explosionPosition ?? CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                }
                
                // Оверлеи
                if showPauseOverlay {
                    PauseOverlayView(isPresented: $showPauseOverlay) {
                        dismiss()
                    }
                }
                
                if viewModel.showVictoryOverlay {
                    VictoryOverlayView(
                        levelId: viewModel.currentLevel.id,
                        onNextLevel: {
                            // Если есть следующий уровень, переходим к нему
                            if viewModel.currentLevel.id < 10 {
                                viewModel.restartLevel()
                                viewModel.currentLevel = LevelModel.generateLevel(id: viewModel.currentLevel.id + 1)
                                viewModel.showVictoryOverlay = false
                            } else {
                                // Если это последний уровень, возвращаемся в меню
                                dismiss()
                            }
                        },
                        onBackToMenu: {
                            dismiss()
                        }
                    )
                }
                
                if viewModel.showDefeatOverlay {
                    DefeatOverlayView(
                        onRestart: {
                            viewModel.restartLevel()
                        },
                        onBackToMenu: {
                            dismiss()
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            AppDelegate.orientationLock = .landscape
        }
    }
}

// Центральная арена
struct CentralArenaView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.3))
                .shadow(radius: 3)
            
            Text("АРЕНА")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
    }
}

// Игровое поле для человека (левая пирамида, вершиной вправо к арене)
struct HumanBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Ряд 0 (5 коробок)
            VStack(spacing: 10) {
                ForEach(0..<5) { colIndex in
                    BoxView(
                        box: viewModel.humanBoxes[0][colIndex],
                        isHighlighted: viewModel.shouldHighlightHumanRow(row: 0),
                        showPlayer: true,
                        onTap: {
                            viewModel.handleHumanBoxTap(row: 0, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 5), height: boxSize(rowCount: 5))
                }
            }
            
            // Ряд 1 (4 коробки)
            VStack(spacing: 10) {
                ForEach(0..<4) { colIndex in
                    BoxView(
                        box: viewModel.humanBoxes[1][colIndex],
                        isHighlighted: viewModel.shouldHighlightHumanRow(row: 1),
                        showPlayer: true,
                        onTap: {
                            viewModel.handleHumanBoxTap(row: 1, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 4), height: boxSize(rowCount: 4))
                }
            }
            
            // Ряд 2 (3 коробки)
            VStack(spacing: 10) {
                ForEach(0..<3) { colIndex in
                    BoxView(
                        box: viewModel.humanBoxes[2][colIndex],
                        isHighlighted: viewModel.shouldHighlightHumanRow(row: 2),
                        showPlayer: true,
                        onTap: {
                            viewModel.handleHumanBoxTap(row: 2, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 3), height: boxSize(rowCount: 3))
                }
            }
            
            // Ряд 3 (2 коробки)
            VStack(spacing: 10) {
                ForEach(0..<2) { colIndex in
                    BoxView(
                        box: viewModel.humanBoxes[3][colIndex],
                        isHighlighted: viewModel.shouldHighlightHumanRow(row: 3),
                        showPlayer: true,
                        onTap: {
                            viewModel.handleHumanBoxTap(row: 3, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 2), height: boxSize(rowCount: 2))
                }
            }
        }
    }
    
    // Определяет размер коробки в зависимости от количества коробок в ряду
    private func boxSize(rowCount: Int) -> CGFloat {
        let baseSize = min(geometry.size.width / 10, geometry.size.height / 10)
        return baseSize
    }
}

// Игровое поле для AI (правая пирамида, вершиной влево к арене)
struct AIBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Ряд 3 (2 коробки)
            VStack(spacing: 10) {
                ForEach(0..<2) { colIndex in
                    BoxView(
                        box: viewModel.aiBoxes[3][colIndex],
                        isHighlighted: viewModel.shouldHighlightAIRow(row: 3),
                        // Игроку не видно, где находится цыпленок AI, пока по нему не попадут
                        showPlayer: viewModel.aiBoxes[3][colIndex].isDestroyed,
                        onTap: {
                            viewModel.handleAIBoxTap(row: 3, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 2), height: boxSize(rowCount: 2))
                }
            }
            
            // Ряд 2 (3 коробки)
            VStack(spacing: 10) {
                ForEach(0..<3) { colIndex in
                    BoxView(
                        box: viewModel.aiBoxes[2][colIndex],
                        isHighlighted: viewModel.shouldHighlightAIRow(row: 2),
                        showPlayer: viewModel.aiBoxes[2][colIndex].isDestroyed,
                        onTap: {
                            viewModel.handleAIBoxTap(row: 2, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 3), height: boxSize(rowCount: 3))
                }
            }
            
            // Ряд 1 (4 коробки)
            VStack(spacing: 10) {
                ForEach(0..<4) { colIndex in
                    BoxView(
                        box: viewModel.aiBoxes[1][colIndex],
                        isHighlighted: viewModel.shouldHighlightAIRow(row: 1),
                        showPlayer: viewModel.aiBoxes[1][colIndex].isDestroyed,
                        onTap: {
                            viewModel.handleAIBoxTap(row: 1, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 4), height: boxSize(rowCount: 4))
                }
            }
            
            // Ряд 0 (5 коробок)
            VStack(spacing: 10) {
                ForEach(0..<5) { colIndex in
                    BoxView(
                        box: viewModel.aiBoxes[0][colIndex],
                        isHighlighted: viewModel.shouldHighlightAIRow(row: 0),
                        showPlayer: viewModel.aiBoxes[0][colIndex].isDestroyed,
                        onTap: {
                            viewModel.handleAIBoxTap(row: 0, column: colIndex)
                        }
                    )
                    .frame(width: boxSize(rowCount: 5), height: boxSize(rowCount: 5))
                }
            }
        }
    }
    
    // Определяет размер коробки в зависимости от количества коробок в ряду
    private func boxSize(rowCount: Int) -> CGFloat {
        let baseSize = min(geometry.size.width / 10, geometry.size.height / 10)
        return baseSize
    }
}

// Представление одной коробки
struct BoxView: View {
    let box: BoxModel
    let isHighlighted: Bool
    let showPlayer: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Фон коробки
                RoundedRectangle(cornerRadius: 8)
                    .fill(boxColor)
                    .shadow(radius: isHighlighted ? 3 : 1)
                
                // Если в коробке есть цыпленок и его нужно показать
                if let player = box.containsPlayer, showPlayer {
                    ChickenView(player: player)
                }
                
                // Если коробка уничтожена
                if box.isDestroyed {
                    Text("💥")
                        .font(.largeTitle)
                }
            }
        }
    }
    
    // Цвет коробки
    private var boxColor: Color {
        if isHighlighted {
            return Color.yellow.opacity(0.5)
        }
        
        if box.isDestroyed {
            return Color.red.opacity(0.3)
        }
        
        return Color.white
    }
}

// Представление цыпленка
struct ChickenView: View {
    let player: GamePlayer
    
    var body: some View {
        ZStack {
            Circle()
                .fill(player == .human ? Color.blue.opacity(0.7) : Color.red.opacity(0.7))
            
            Text("🐥")
                .font(.body)
        }
    }
}

// Анимация яйца
struct EggView: View {
    var body: some View {
        Text("🥚")
            .font(.title)
    }
}

// Анимация взрыва
struct ExplosionView: View {
    var body: some View {
        Text("💥")
            .font(.largeTitle)
    }
}

#Preview {
    GameView(levelId: 1, appState: AppState())
}
