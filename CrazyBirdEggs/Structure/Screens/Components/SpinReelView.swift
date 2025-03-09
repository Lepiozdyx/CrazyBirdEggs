import SwiftUI

struct SpinReelView: View {
    @StateObject private var reelViewModel = ReelViewModel()
    @ObservedObject var appState: AppState
    
    #if DEBUG
    @State private var showDebugOptions = false
    #endif
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // MARK: - DEBUG
            #if DEBUG
//            VStack {
//                Button {
//                    showDebugOptions.toggle()
//                } label: {
//                    Image(systemName: "ladybug")
//                        .font(.title)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                
//                if showDebugOptions {
//                    VStack(spacing: 10) {
//                        Button("Reset") {
//                            reelViewModel.resetLockForDebug()
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        
//                        Button("Set 1h timer") {
//                            reelViewModel.setDebugTimer(hours: 1)
//                        }
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                }
//            }
            #endif
            // MARK: - endif
            
            Button {
                SettingsManager.shared.getTapSound()
                if !reelViewModel.isSpinning && !reelViewModel.isLocked {
                    reelViewModel.spinReel(onComplete: { points in
                        appState.addScore(points: points)
                    })
                }
            } label: {
                ZStack {
                    Image(.reel)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .rotationEffect(.degrees(reelViewModel.rotationAngle))
                        .overlay {
                            Image(.arrow)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.9)
                        }
                    
                    if reelViewModel.showLockOverlay {
                        VStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.black)
                            
                            Text("\(reelViewModel.hoursRemaining)h")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .shadow(color: .black, radius: 2)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(reelViewModel.isSpinning || reelViewModel.isLocked)
            
            if reelViewModel.showReward {
                Text("+\(reelViewModel.rewardPoints) points!")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 1)
                    .transition(.scale.combined(with: .opacity))
                    .padding(10)
                    .background(
                        Image(.topbarrectangle)
                            .resizable()
                            .clipShape(.rect(cornerRadius: 8))
                    )
                    .offset(x: -140, y: -30)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                reelViewModel.showReward = false
                            }
                        }
                    }
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .onAppear {
            reelViewModel.checkLockStatus()
        }
    }
}

#Preview {
    SpinReelView(appState: AppState())
}
