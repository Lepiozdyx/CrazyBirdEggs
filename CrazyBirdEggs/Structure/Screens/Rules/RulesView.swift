import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        OrientationRestrictedView(requiredOrientation: .landscape, restrictionMessage: "Use landscape orientation for better experience") {
            ZStack {
                Image(.background4)
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 4, opaque: true)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        Image(.goal)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 150)
                        
                        Image(.rule1)
                            .resizable()
                            .scaledToFit()
                        
                        Image(.howtoplay)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250)
                        
                        HStack(alignment: .top) {
                            Image(.rule2)
                                .resizable()
                                .scaledToFit()
                            
                            Image(.rule3)
                                .resizable()
                                .scaledToFit()
                            
                            Image(.rule4)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .padding(20)
                }
                
                VStack {
                    HStack(alignment: .top) {
                        Button {
                            SettingsManager.shared.getTapSound()
                            dismiss()
                        } label: {
                            Image(.backbutton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    RulesView()
}
