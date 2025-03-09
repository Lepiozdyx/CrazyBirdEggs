//
import SwiftUI

struct ActionView: View {
    let button: ImageResource
    let text: ImageResource
    
    var body: some View {
        Image(button)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 200)
            .overlay {
                Image(text)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120)
                    .offset(y: -10)
            }
    }
}

#Preview {
    ActionView(button: .button, text: .rateUs)
}
