import SwiftUI

struct BoxView: View {
    let box: BoxModel
    let isHighlighted: Bool
    let showPlayer: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Удаляем все связанное с анимацией, так как это будет на уровне ряда
                
                // Отображение коробки в зависимости от состояния
                if let imageName = box.boxImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                }
                
                // Показываем цыпленка только если нужно
                if box.shouldShowChicken && box.containsPlayer != nil {
                    ChickenView(player: box.containsPlayer!)
                }
            }
        }
        .disabled(box.isDestroyed || box.boxState == .explosion || box.boxState == .onlyChicken)
    }
}
