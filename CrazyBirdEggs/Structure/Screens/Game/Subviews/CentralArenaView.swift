import SwiftUI

struct CentralArenaView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.clear)
                .frame(maxWidth: 90, maxHeight: 90)
                .offset(y: -35)
            
            if viewModel.showingCentralArenaChicken {
                switch viewModel.arenaState {
                case .showingHumanChicken:
                    Image(.hero)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 60)
                    
                case .showingAIChicken:
                    Image(.lvl1)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 60)
                        .scaleEffect(x: -1)
                    
                default:
                    EmptyView()
                }
            }
        }
    }
}
