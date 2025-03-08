import SwiftUI

struct BoxView: View {
    let box: BoxModel
    let isHighlighted: Bool
    let showPlayer: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            SettingsManager.shared.getTapSound()
            onTap()
        } label: {
            ZStack {
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
