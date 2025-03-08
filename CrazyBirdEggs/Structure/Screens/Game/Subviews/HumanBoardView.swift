import SwiftUI

struct HumanBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: 10) {
            // Ряд 0 (5 коробок)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 0)) {
                VStack(spacing: 10) {
                    ForEach(0..<5) { colIndex in
                        BoxView(
                            box: viewModel.humanBoxes[0][colIndex],
                            isHighlighted: viewModel.shouldHighlightHumanRow(row: 0),
                            showPlayer: true,
                            onTap: {
                                viewModel.handleHumanBoxTap(row: 0, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 5), height: boxSize(rowCount: 5))
                    }
                }
            }
            
            // Ряд 1 (4 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 1)) {
                VStack(spacing: 10) {
                    ForEach(0..<4) { colIndex in
                        BoxView(
                            box: viewModel.humanBoxes[1][colIndex],
                            isHighlighted: viewModel.shouldHighlightHumanRow(row: 1),
                            showPlayer: true,
                            onTap: {
                                viewModel.handleHumanBoxTap(row: 1, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 4), height: boxSize(rowCount: 4))
                    }
                }
            }
            
            // Ряд 2 (3 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 2)) {
                VStack(spacing: 10) {
                    ForEach(0..<3) { colIndex in
                        BoxView(
                            box: viewModel.humanBoxes[2][colIndex],
                            isHighlighted: viewModel.shouldHighlightHumanRow(row: 2),
                            showPlayer: true,
                            onTap: {
                                viewModel.handleHumanBoxTap(row: 2, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 3), height: boxSize(rowCount: 3))
                    }
                }
            }
            
            // Ряд 3 (2 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightHumanRow(row: 3)) {
                VStack(spacing: 10) {
                    ForEach(0..<2) { colIndex in
                        BoxView(
                            box: viewModel.humanBoxes[3][colIndex],
                            isHighlighted: viewModel.shouldHighlightHumanRow(row: 3),
                            showPlayer: true,
                            onTap: {
                                viewModel.handleHumanBoxTap(row: 3, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 2), height: boxSize(rowCount: 2))
                    }
                }
            }
        }
    }
    
    // Определяет размер коробки в зависимости от количества коробок в ряду
    private func boxSize(rowCount: Int) -> CGFloat {
        let baseSize = min(geometry.size.width / 10, geometry.size.height / 10)
        return baseSize
    }
}
