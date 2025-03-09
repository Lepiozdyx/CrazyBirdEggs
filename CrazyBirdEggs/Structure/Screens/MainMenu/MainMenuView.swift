import SwiftUI

struct MainMenuView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        NavigationView {
            OrientationRestrictedView(requiredOrientation: .landscape, restrictionMessage: "Use landscape orientation for better experience") {
                ZStack {
                    Image(.background2)
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack {
                        // MARK: Top panel
                        HStack {
                            // MARK: Settings panel
                            SettingsPanelView()
                            Spacer()
                            
                            #if DEBUG
                            Button {
                                appState.resetProgress()
                            } label: {
                                Text("Reset all")
                                    .font(.title3)
                                    .padding(4)
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            #endif
                            
                            Image(.counterFrame)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 150)
                                .overlay {
                                    Text("\(appState.totalScore)")
                                        .font(.system(size: 18, weight: .bold, design: .serif))
                                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                                        .foregroundStyle(.yellow)
                                        .offset(x: 10, y: 8)
                                }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            SpinReelView(appState: appState)
//                                .background()
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
                            NavigationLink {
                                LevelSelectionView(appState: appState)
                            } label: {
                                ActionView(button: .button, text: .start)
                            }
                            
                            NavigationLink {
                                ShopView(appState: appState)
                            } label: {
                                ActionView(button: .button, text: .shop)
                            }
                            
                            NavigationLink {
                                 RulesView()
                            } label: {
                                ActionView(button: .button, text: .rules)
                            }
                            
                            Button {
                                settings.rateApp()
                            } label: {
                                ActionView(button: .buttonRed, text: .rateUs)
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {}
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            settings.playBackgroundMusic()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                settings.playBackgroundMusic()
            case .background, .inactive:
                settings.stopBackgroundMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    MainMenuView()
}
