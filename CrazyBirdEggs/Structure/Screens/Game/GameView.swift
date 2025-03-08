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
                    // MARK: Top panel
                    HStack {
                        // MARK: PauseOverlay
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
                        
                        // MARK: Game messages
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
                    
                    // MARK: Game field
                    HStack(spacing: 10) {
                        // MARK: Hero Image
                        Image(.hero)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 60)
                        
                        // MARK: HumanBoardView
                        HumanBoardView(
                            viewModel: viewModel,
                            geometry: geometry
                        )
                        
                        // MARK: CentralArenaView
                        CentralArenaView(viewModel: viewModel)
                        
                        // MARK: AIBoardView
                        AIBoardView(
                            viewModel: viewModel,
                            geometry: geometry
                        )
                        
                        // MARK: Enemy Image
                        EnemyImageProvider.getEnemyImage(for: viewModel.currentLevel.id)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 70)
                            .scaleEffect(x: -1)
                    }
                    
                    Spacer()
                }
                
                // MARK: PauseOverlayView
                if showPauseOverlay {
                    PauseOverlayView(isPresented: $showPauseOverlay) {
                        dismiss()
                    }
                }
                
                // MARK: VictoryOverlayView
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
                
                // MARK: DefeatOverlayView
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

#Preview {
    GameView(levelId: 1, appState: AppState())
}
