import SwiftUI

struct ShopView: View {
    @StateObject private var viewModel = ShopViewModel()
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        OrientationRestrictedView(requiredOrientation: .landscape, restrictionMessage: "Use landscape orientation for better experience") {
            ZStack {
                Image(.background3)
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 3, opaque: true)
                
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
                        
                        Image(.chikenskin)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                        
                        Spacer()
                        
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
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.availableSkins) { skin in
                                ShopButtonView(skin: skin, isBought: viewModel.isSkinBought(skin), isSelected: skin.id == viewModel.selectedSkin, buy: {
                                    if appState.spend(skin.price) {
                                        viewModel.buySkin(skin)
                                    }
                                }, select: {
                                    viewModel.selectSkin(skin)
                                }
                                )
                            }
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ShopView(appState: AppState())
}
