import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
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
                        Button(action: {
                            showPauseOverlay = true
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }
                        .padding(.leading)
                        
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
                            .padding(.trailing)
                    }
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Игровое поле с двумя пирамидами коробок
                    HStack(spacing: 50) {
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
                    .padding(.horizontal)
                    
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
                        // Действие для возврата в меню
                        presentationMode.wrappedValue.dismiss()
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
                                presentationMode.wrappedValue.dismiss()
                            }
                        },
                        onBackToMenu: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
                
                if viewModel.showDefeatOverlay {
                    DefeatOverlayView(
                        onRestart: {
                            viewModel.restartLevel()
                        },
                        onBackToMenu: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Устанавливаем ориентацию
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

// Игровое поле для человека (левая пирамида)
struct HumanBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 15) {
            // Отображаем ряды коробок от 0 до 3 (4 ряда)
            ForEach((0...3).reversed(), id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(0..<viewModel.humanBoxes[rowIndex].count, id: \.self) { colIndex in
                        BoxView(
                            box: viewModel.humanBoxes[rowIndex][colIndex],
                            isHighlighted: viewModel.shouldHighlightHumanRow(row: rowIndex),
                            showPlayer: true,
                            onTap: {
                                viewModel.handleHumanBoxTap(row: rowIndex, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowIndex: rowIndex), height: boxSize(rowIndex: rowIndex))
                    }
                }
            }
        }
    }
    
    // Определяет размер коробки в зависимости от ряда
    private func boxSize(rowIndex: Int) -> CGFloat {
        let baseSize = min(geometry.size.width / 10, geometry.size.height / 10)
        return baseSize
    }
}

// Игровое поле для AI (правая пирамида)
struct AIBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 15) {
            // Отображаем ряды коробок от 0 до 3 (4 ряда)
            ForEach((0...3).reversed(), id: \.self) { rowIndex in
                HStack(spacing: 10) {
                    ForEach(0..<viewModel.aiBoxes[rowIndex].count, id: \.self) { colIndex in
                        BoxView(
                            box: viewModel.aiBoxes[rowIndex][colIndex],
                            isHighlighted: viewModel.shouldHighlightAIRow(row: rowIndex),
                            // Игроку не видно, где находится цыпленок AI, пока по нему не попадут
                            showPlayer: viewModel.aiBoxes[rowIndex][colIndex].isDestroyed,
                            onTap: {
                                viewModel.handleAIBoxTap(row: rowIndex, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowIndex: rowIndex), height: boxSize(rowIndex: rowIndex))
                    }
                }
            }
        }
    }
    
    // Определяет размер коробки в зависимости от ряда
    private func boxSize(rowIndex: Int) -> CGFloat {
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
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.red)
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
