import SwiftUI

struct ChickenView: View {
    let player: GamePlayer
    
    var body: some View {
        Image(.hero)
            .resizable()
            .scaledToFit()
            .scaleEffect(x: player == .human ? 1 : -1)
    }
}
