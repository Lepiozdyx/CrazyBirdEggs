import SwiftUI

struct ShopButtonView: View {
    let skin: HeroSkin
    let isBought: Bool
    let isSelected: Bool
    let buy: () -> Void
    let select: () -> Void
    
    var body: some View {
        ZStack {
            Button {
                SettingsManager.shared.getTapSound()
                if !isBought {
                    buy()
                } else if !isSelected {
                    select()
                }
            } label: {
                VStack(spacing: 10) {
                    Text(skin.price > 0 ? "\(skin.price)" : "Free")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                        .foregroundStyle(.yellow)
                    
                    Image(skin.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.ultraThinMaterial)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? .white : .clear, lineWidth: 8)
                                .animation(.easeInOut, value: isSelected)
                        }
                    
                    Image(isSelected
                          ? .equiped
                          : isBought ? .equip : .buy
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(8)
                    .background(
                        Capsule()
                            .foregroundStyle(isSelected
                                             ? .clear
                                             : isBought ? .lightGreen : .lightYellow
                            )
                            .animation(.easeInOut, value: isSelected)
                            .animation(.easeInOut, value: isBought)
                    )
                }
            }
            .buttonStyle(.plain)
            .disabled(isSelected)
        }
    }
}

#Preview {
    ZStack {
        Image(.background3)
            .resizable()
            .ignoresSafeArea()
            .blur(radius: 3, opaque: true)
        
        ShopButtonView(
            skin: HeroSkin(id: 0, image: .hero2, price: 0),
            isBought: false,
            isSelected: false,
            buy: {},
            select: {}
        )
    }
}
