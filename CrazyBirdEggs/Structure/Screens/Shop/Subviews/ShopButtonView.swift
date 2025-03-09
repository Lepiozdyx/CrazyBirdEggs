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
                if !isBought {
                    buy()
                } else {
                    select()
                }
            } label: {
                VStack(spacing: 10) {
                    Text("\(skin.price)")
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
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        Image(.background3)
            .resizable()
            .ignoresSafeArea()
            .blur(radius: 3, opaque: true)
        
        ShopButtonView(skin: HeroSkin.init(id: 1, image: .hero2, price: 300), isBought: false, isSelected: false, buy: {}, select: {})
    }
}
