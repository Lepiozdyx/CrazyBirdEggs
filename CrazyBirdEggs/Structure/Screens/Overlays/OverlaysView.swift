import SwiftUI

// MARK: - PAUSE
struct PauseOverlayView: View {
    @Binding var isPresented: Bool
    var onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            Image(.chickenBackground)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 450)
            
            Image(.table1)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280)
                .offset(y: 50)
            
            // Контент
            VStack(spacing: 40) {
                // Кнопки
                VStack(spacing: 15) {
                    // Вернуться в игру
                    Button {
                        isPresented = false
                    } label: {
                        Image(.resume)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                    }
                    
                    // Выйти в меню
                    Button(action: onBackToMenu) {
                        Image(.menu)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 170)
                    }
                }
            }
            .offset(y: 55)
        }
    }
}

// MARK: - WIN
struct VictoryOverlayView: View {
    let levelId: Int
    var onNextLevel: () -> Void
    var onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            Image(.salut)
                .resizable()
                .opacity(0.7)
            
            VStack {
                Image(.win)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 250)
                    .padding(.top, 40)
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Image(.trumpetRight)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                    
                    Spacer()

                    Image(.trumpetLeft)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                }
            }
            .opacity(0.7)
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                Spacer()
                // Следующий уровень (если не последний)
                if levelId < 10 {
                    Button(action: onNextLevel) {
                        VStack {
                            Image(.quill)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 150)
                                .overlay(alignment: .bottom) {
                                    Image(._100)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 80)
                                }
                            
                            Image(.taptoclaim)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 150)
                        }
                    }
                }
                
                // Выйти в меню
                Button(action: onBackToMenu) {
                    Image(.menu)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 170)
                }
                Spacer()
            }
        }
    }
}

// MARK: - LOOSE
struct DefeatOverlayView: View {
    var onRestart: () -> Void
    var onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack {
                Image(.lose)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 250)
                    .padding(.top, 40)
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Image(.sadTrumpetLeft)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                    
                    Spacer()

                    Image(.sadTrumpetRight)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                }
            }
            .opacity(0.7)
            .ignoresSafeArea()
            
            // Контент
            VStack(spacing: 30) {
                Spacer()
                Spacer()
                Button(action: onRestart) {
                    VStack(spacing: -10) {
                        Image(.friedChicken)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 150)
                        
                        Image(.restart)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 150)
                    }
                }
                
                // Выйти в меню
                Button(action: onBackToMenu) {
                    Image(.menu)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 170)
                }
                Spacer()
            }
        }
    }
}

// MARK: - PREVIEW
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
