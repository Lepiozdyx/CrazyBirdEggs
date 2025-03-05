import SwiftUI

struct MainMenuView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                Color.gray.opacity(0.2).ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Информация о прогрессе
                    VStack(alignment: .center, spacing: 10) {
                        Text("Разблокировано уровней: \(appState.unlockedLevels)/10")
                            .font(.headline)
                        
                        Text("Общий счёт: \(appState.totalScore)")
                            .font(.headline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 2)
                    )
                    
                    Spacer()
                    
                    // Кнопка "Играть"
                    NavigationLink(destination: LevelSelectionView(appState: appState)) {
                        Text("Играть")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                    }
                    
                    // Для отладки: кнопка сброса прогресса
                    #if DEBUG
                    Button {
                        appState.resetProgress()
                    } label: {
                        Text("Сбросить прогресс")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 20)
                    #endif
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onAppear {
                // Проверяем ориентацию устройства
                if UIDevice.current.orientation.isPortrait {
                    // Показываем предупреждение о необходимости горизонтальной ориентации
                    showOrientationWarning()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // Функция для отображения предупреждения об ориентации
    private func showOrientationWarning() {
        let alertController = UIAlertController(
            title: "Внимание",
            message: "Игра предназначена для горизонтальной ориентации. Пожалуйста, поверните устройство.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true)
        }
    }
}

#Preview {
    MainMenuView()
}
