import SwiftUI

struct SettingsPanelView: View {
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        HStack(spacing: 15) {
//            Button {
//                withAnimation {
//                    
//                }
//            } label: {
//                Image(isOn ? .vibrobutton : .xvibrobutton)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 50)
//            }
            
            Button {
                withAnimation {
                    settings.toggleMusic()
                }
            } label: {
                Image(settings.isMusicOn ? .musicbutton : .xmusicbutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
            
            Button {
                withAnimation {
                    settings.toggleSound()
                }
            } label: {
                Image(settings.isSoundOn ? .soundbutton : .xsoundbutton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
    }
}

#Preview {
    SettingsPanelView()
}
