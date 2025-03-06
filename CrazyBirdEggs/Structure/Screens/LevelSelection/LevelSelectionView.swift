import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let rows = [
        GridItem(
            .adaptive(minimum: 120, maximum: 240),
            spacing: 20,
            alignment: .center
        )
    ]
    
    var body: some View {
        OrientationRestrictedView(requiredOrientation: .landscape, restrictionMessage: "Use landscape orientation for better experience") {
            ZStack {
                Image(.background1)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    HStack(alignment: .top) {
                        Button {
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
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Сетка уровней
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, spacing: 20) {
                        ForEach(1...10, id: \.self) { level in
                            NavigationLink(
                                destination: GameViewWrapper(levelId: level, appState: appState))
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
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Cell
struct LevelCell: View {
    let level: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: -40) {
                Image(.chickenLvl1)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 90)
                
                Image(.ground)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)
            }
            
            Text("\(level)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .colorMultiply(isUnlocked ? .white : .gray)
    }
}

#Preview {
    NavigationView {
        LevelSelectionView(appState: AppState())
    }
}
