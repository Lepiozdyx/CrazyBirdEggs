import SwiftUI

struct BoxView: View {
    let box: BoxModel
    let isHighlighted: Bool
    let showPlayer: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            SettingsManager.shared.getTapSound()
            
            if box.isDestroyed || box.boxState == .explosion || box.boxState == .onlyChicken {
                SettingsManager.shared.getWarningVibration()
            } else {
                SettingsManager.shared.getVibration(style: .medium)
            }
            
            onTap()
        } label: {
            ZStack {
                if let imageName = box.boxImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                }
                
                if box.shouldShowChicken && box.containsPlayer != nil {
                    ChickenView(player: box.containsPlayer!)
                }
            }
        }
        .disabled(box.isDestroyed || box.boxState == .explosion || box.boxState == .onlyChicken)
    }
}
