import SwiftUI

// Оверлей паузы
struct PauseOverlayView: View {
    @Binding var isPresented: Bool
    var onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // Контент
            VStack(spacing: 30) {
                Text("Пауза")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Кнопки
                VStack(spacing: 15) {
                    // Вернуться в игру
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Вернуться в игру")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    // Выйти в меню
                    Button(action: onBackToMenu) {
                        Text("Выйти в меню")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.8))
                    .shadow(radius: 10)
            )
        }
    }
}

// Оверлей победы
struct VictoryOverlayView: View {
    let levelId: Int
    var onNextLevel: () -> Void
    var onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // Контент
            VStack(spacing: 25) {
                Text("Победа!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("+100 очков")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                // Кнопки
                VStack(spacing: 15) {
                    // Следующий уровень (если не последний)
                    if levelId < 10 {
                        Button(action: onNextLevel) {
                            Text("Следующий уровень")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Выйти в меню
                    Button(action: onBackToMenu) {
                        Text("В меню")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green.opacity(0.2))
                    .shadow(radius: 10)
            )
        }
    }
}

// Оверлей поражения
struct DefeatOverlayView: View {
    var onRestart: () -> Void
    var onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // Контент
            VStack(spacing: 30) {
                Text("Поражение")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Кнопки
                VStack(spacing: 15) {
                    // Перезапустить уровень
                    Button(action: onRestart) {
                        Text("Рестарт уровня")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    
                    // Выйти в меню
                    Button(action: onBackToMenu) {
                        Text("В меню")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red.opacity(0.2))
                    .shadow(radius: 10)
            )
        }
    }
}

#Preview("Pause Overlay") {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        
        PauseOverlayView(isPresented: .constant(true)) {
            // Действие для возврата в меню
        }
    }
}
    
#Preview("Victory Overlay") {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        
        VictoryOverlayView(
            levelId: 5,
            onNextLevel: {},
            onBackToMenu: {}
        )
    }
}
 
#Preview("Defeat Overlay") {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        
        DefeatOverlayView(
            onRestart: {},
            onBackToMenu: {}
        )
    }
}
