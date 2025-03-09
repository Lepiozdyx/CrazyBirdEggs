import SwiftUI

struct LoadingView: View {
    @State private var currentEggIndex = 0

    private let eggImages: [ImageResource] = [.egg1, .egg2, .egg3, .egg4]
    let timer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(.loadingBG)
                .resizable()
                .ignoresSafeArea()
                
            HStack {
                Spacer()
                
                VStack(alignment: .trailing) {
                    Spacer()

                    Image(eggImages[currentEggIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                    
                    Image(.download)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            withAnimation(.default) {
                currentEggIndex = (currentEggIndex + 1) % eggImages.count
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

#Preview {
    LoadingView()
}
