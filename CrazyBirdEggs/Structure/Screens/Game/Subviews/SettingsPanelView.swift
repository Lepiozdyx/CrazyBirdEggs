import SwiftUI

struct SettingsPanelView: View {
    var body: some View {
        HStack(spacing: 15) {
            Button {
                
            } label: {
                Image(.vibrobutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
            
            Button {
                
            } label: {
                Image(.musicbutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
            
            Button {
                
            } label: {
                Image(.soundbutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
    }
}
