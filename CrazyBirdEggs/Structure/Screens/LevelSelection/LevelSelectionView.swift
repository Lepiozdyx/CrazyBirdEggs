import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // Фон
            Color.gray.opacity(0.2).ignoresSafeArea()
            
            VStack {
                // Заголовок
                Text("Выберите уровень")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Сетка уровней
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(1...10, id: \.self) { level in
                            NavigationLink(destination: GameView(levelId: level, appState: appState)) {
                                LevelCell(level: level, isUnlocked: level <= appState.unlockedLevels)
                            }
                            .disabled(level > appState.unlockedLevels)
                        }
                    }
                    .padding()
                }
                
                // Кнопка "Назад"
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Назад")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .padding(.bottom)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Устанавливаем предпочтительную ориентацию для данного экрана
            AppDelegate.orientationLock = .landscape
        }
    }
}

// Ячейка для отображения уровня
struct LevelCell: View {
    let level: Int
    let isUnlocked: Bool
    
    var body: some View {
        VStack {
            Text("Уровень \(level)")
                .font(.headline)
                .fontWeight(.semibold)
            
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.blue : Color.gray.opacity(0.5))
                    .frame(width: 80, height: 80)
                
                Text("\(level)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: isUnlocked ? 3 : 1)
        )
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

#Preview {
    NavigationView {
        LevelSelectionView(appState: AppState())
    }
}
