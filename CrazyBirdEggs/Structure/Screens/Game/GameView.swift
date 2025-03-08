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
                Image(.battlemap)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // MARK: Верхняя панель
                    HStack {
                        // MARK: Кнопка паузы
                        Button {
                            showPauseOverlay = true
                        } label: {
                            Image(.pausebutton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                        }
                        
                        Spacer()
                        Spacer()
                        
                        // MARK: Сообщение об игровой фазе
                        Text(viewModel.gameMessage)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background(
                                Image(.topbarrectangle)
                                    .resizable()
                                    .clipShape(.rect(cornerRadius: 10))
                            )
                        
                        Spacer()
                        
                        // MARK: Settings panel
                        SettingsPanelView()
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    // MARK: Игровое поле
                    HStack(spacing: 10) {
                        // MARK: Герой игрока
                        Image(.hero)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 60)
                        
                        // MARK: Коробки игрока
                        HumanBoardView(
                            viewModel: viewModel,
                            geometry: geometry
                        )
                        
                        // MARK: Центр
                        CentralArenaView(viewModel: viewModel)
                        
                        // MARK: Коробки компьютера
                        AIBoardView(
                            viewModel: viewModel,
                            geometry: geometry
                        )
                        
                        // MARK: Герой компьюетра
                        EnemyImageProvider.getEnemyImage(for: viewModel.currentLevel.id)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 70)
                            .scaleEffect(x: -1)
                    }
                    
                    Spacer()
                }
                
                // MARK: Оверлеи
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
    }
}

// MARK: - Игровое поле для человека (левая пирамида, вершиной вправо к арене)
struct HumanBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: 10) {
            // Ряд 0 (5 коробок)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 0)) {
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
            }
            
            // Ряд 1 (4 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 1)) {
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
            }
            
            // Ряд 2 (3 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 2)) {
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
            }
            
            // Ряд 3 (2 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 3)) {
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
        HStack(spacing: 10) {
            // Ряд 3 (2 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 3)) {
                VStack(spacing: 10) {
                    ForEach(0..<2) { colIndex in
                        BoxView(
                            box: viewModel.aiBoxes[3][colIndex],
                            isHighlighted: viewModel.shouldHighlightAIRow(row: 3),
                            showPlayer: viewModel.aiBoxes[3][colIndex].isDestroyed,
                            onTap: {
                                viewModel.handleAIBoxTap(row: 3, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 2), height: boxSize(rowCount: 2))
                    }
                }
            }
            
            // Ряд 2 (3 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 2)) {
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
            }
            
            // Ряд 1 (4 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 1)) {
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
            }
            
            // Ряд 0 (5 коробок)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 0)) {
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
    }
    
    // Определяет размер коробки в зависимости от количества коробок в ряду
    private func boxSize(rowCount: Int) -> CGFloat {
        let baseSize = min(geometry.size.width / 10, geometry.size.height / 10)
        return baseSize
    }
}

// MARK: - BoxView
struct BoxView: View {
    let box: BoxModel
    let isHighlighted: Bool
    let showPlayer: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Удаляем все связанное с анимацией, так как это будет на уровне ряда
                
                // Отображение коробки в зависимости от состояния
                if let imageName = box.boxImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                }
                
                // Показываем цыпленка только если нужно
                if box.shouldShowChicken && box.containsPlayer != nil {
                    ChickenView(player: box.containsPlayer!)
                }
            }
        }
        .disabled(box.isDestroyed || box.boxState == .explosion || box.boxState == .onlyChicken)
    }
}

struct AnimatedRowView<Content: View>: View {
    let isHighlighted: Bool
    let content: Content
    @State private var pulseScale: CGFloat = 1.0
    
    init(isHighlighted: Bool, @ViewBuilder content: () -> Content) {
        self.isHighlighted = isHighlighted
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHighlighted ? .yellow.opacity(0.7) : .clear)
                    .scaleEffect(isHighlighted ? pulseScale : 1.0)
                    .animation(
                        isHighlighted ?
                            .easeInOut(duration: 0.5).repeatCount(5) :
                            nil,
                        value: pulseScale
                    )
            )
            .onAppear {
                // Установить начальное значение анимации при появлении
                if isHighlighted {
                    pulseScale = 1.05
                }
            }
            .onChange(of: isHighlighted) { newValue in
                // Сбросить значение при изменении подсветки
                if !newValue {
                    pulseScale = 1.0
                } else {
                    // При активации подсветки установить значение для начала анимации
                    pulseScale = 1.05
                }
            }
    }
}

// Представление для центральной арены
struct CentralArenaView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Фон арены
            Rectangle()
                .fill(.clear)
                .frame(maxWidth: 90, maxHeight: 90)
                .offset(y: -35)
            
            // Отображение цыпленка в арене, если нужно
            if viewModel.showingCentralArenaChicken {
                switch viewModel.arenaState {
                case .showingHumanChicken:
                    // Цыпленок игрока в арене
                    Image(.hero)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 60)
                    
                case .showingAIChicken:
                    // Цыпленок ИИ в арене
                    Image(.lvl1)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 60)
                        .scaleEffect(x: -1)
                    
                default:
                    // Ничего не показываем в других состояниях
                    EmptyView()
                }
            }
        }
    }
}

// Представление цыпленка
struct ChickenView: View {
    let player: GamePlayer
    
    var body: some View {
        Image(.hero)
            .resizable()
            .scaledToFit()
            .scaleEffect(x: player == .human ? 1 : -1)
    }
}

#Preview {
    GameView(levelId: 1, appState: AppState())
}

// MARK: - SettingsPanelView
struct SettingsPanelView: View {
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Image(.vibrobutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
            
            Button {
                
            } label: {
                Image(.musicbutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
            
            Button {
                
            } label: {
                Image(.soundbutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
    }
}
