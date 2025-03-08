import SwiftUI

struct AIBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: 10) {
            // Ряд 3 (2 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 3)) {
                VStack(spacing: 10) {
                    ForEach(0..<2) { colIndex in
                        BoxView(
                            box: viewModel.aiBoxes[3][colIndex],
                            isHighlighted: viewModel.shouldHighlightAIRow(row: 3),
                            showPlayer: viewModel.aiBoxes[3][colIndex].isDestroyed,
                            onTap: {
                                viewModel.handleAIBoxTap(row: 3, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 2), height: boxSize(rowCount: 2))
                    }
                }
            }
            
            // Ряд 2 (3 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 2)) {
                VStack(spacing: 10) {
                    ForEach(0..<3) { colIndex in
                        BoxView(
                            box: viewModel.aiBoxes[2][colIndex],
                            isHighlighted: viewModel.shouldHighlightAIRow(row: 2),
                            showPlayer: viewModel.aiBoxes[2][colIndex].isDestroyed,
                            onTap: {
                                viewModel.handleAIBoxTap(row: 2, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 3), height: boxSize(rowCount: 3))
                    }
                }
            }
            
            // Ряд 1 (4 коробки)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 1)) {
                VStack(spacing: 10) {
                    ForEach(0..<4) { colIndex in
                        BoxView(
                            box: viewModel.aiBoxes[1][colIndex],
                            isHighlighted: viewModel.shouldHighlightAIRow(row: 1),
                            showPlayer: viewModel.aiBoxes[1][colIndex].isDestroyed,
                            onTap: {
                                viewModel.handleAIBoxTap(row: 1, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 4), height: boxSize(rowCount: 4))
                    }
                }
            }
            
            // Ряд 0 (5 коробок)
            AnimatedRowView(isHighlighted: viewModel.shouldHighlightAIRow(row: 0)) {
                VStack(spacing: 10) {
                    ForEach(0..<5) { colIndex in
                        BoxView(
                            box: viewModel.aiBoxes[0][colIndex],
                            isHighlighted: viewModel.shouldHighlightAIRow(row: 0),
                            showPlayer: viewModel.aiBoxes[0][colIndex].isDestroyed,
                            onTap: {
                                viewModel.handleAIBoxTap(row: 0, column: colIndex)
                            }
                        )
                        .frame(width: boxSize(rowCount: 5), height: boxSize(rowCount: 5))
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
