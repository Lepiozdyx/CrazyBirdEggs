import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        OrientationRestrictedView(requiredOrientation: .landscape, restrictionMessage: "Use landscape orientation for better experience") {
            ZStack {
                Image(.background1)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    Image(.topbarrectangle)
                        .resizable()
                        .frame(maxHeight: 90)
                    
                    Spacer()
                    
                    Image(.bottombarrectangle)
                        .resizable()
                        .scaledToFit()
                }
                .ignoresSafeArea()
                
                VStack {
                    HStack(alignment: .top) {
                        Button {
                            SettingsManager.shared.getTapSound()
                            dismiss()
                        } label: {
                            Image(.backbutton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        
                        Spacer()
                        
                        Image(.selectLvl)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 350)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Сетка уровней
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(1...10, id: \.self) { level in
                                NavigationLink(destination: GameViewWrapper(levelId: level, appState: appState))
                                {
                                    LevelCell(level: level,
                                              isUnlocked: level <= appState.unlockedLevels,
                                              isCompleted: appState.isLevelCompleted(levelId: level))
                                }
                                .disabled(level > appState.unlockedLevels)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Cell
struct LevelCell: View {
    
    // TODO: - Stars
    
    let level: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    
    var body: some View {
        Image(.ground)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 250)
            .overlay {
                EnemyImageProvider.getEnemyImage(for: level)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 90)
                    .offset(y: -55)
                    .overlay(alignment: .top) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 18))
                            Image(systemName: "star.fill")
                                .font(.system(size: 18))
                                .offset(y: -5)
                            Image(systemName: "star")
                                .font(.system(size: 18))
                        }
                        .foregroundStyle(isUnlocked ? .yellow : .clear)
                        .offset(y: -75)
                    }
            }
            .overlay {
                Image("\(level)")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 45)
            }
            .colorMultiply(isUnlocked ? .white : .gray)
    }
}

#Preview {
    NavigationView {
        LevelSelectionView(appState: AppState())
    }
}
