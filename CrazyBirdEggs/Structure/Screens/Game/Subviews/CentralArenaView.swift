import SwiftUI

struct CentralArenaView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Фон арены
            Rectangle()
                .fill(.clear)
                .frame(maxWidth: 90, maxHeight: 90)
                .offset(y: -35)
            
            // Отображение цыпленка в арене, если нужно
            if viewModel.showingCentralArenaChicken {
                switch viewModel.arenaState {
                case .showingHumanChicken:
                    // Цыпленок игрока в арене
                    Image(.hero)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 60)
                    
                case .showingAIChicken:
                    // Цыпленок ИИ в арене
                    Image(.lvl1)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 60)
                        .scaleEffect(x: -1)
                    
                default:
                    // Ничего не показываем в других состояниях
                    EmptyView()
                }
            }
        }
    }
}
