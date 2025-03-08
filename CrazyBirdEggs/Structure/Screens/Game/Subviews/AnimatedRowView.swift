import SwiftUI

struct AnimatedRowView<Content: View>: View {
    let isHighlighted: Bool
    let content: Content
    @State private var pulseScale: CGFloat = 1.0
    
    init(isHighlighted: Bool, @ViewBuilder content: () -> Content) {
        self.isHighlighted = isHighlighted
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHighlighted ? .yellow.opacity(0.7) : .clear)
                    .scaleEffect(isHighlighted ? pulseScale : 1.0)
                    .animation(
                        isHighlighted ?
                            .easeInOut(duration: 0.5).repeatCount(5) :
                            nil,
                        value: pulseScale
                    )
            )
            .onAppear {
                // Установить начальное значение анимации при появлении
                if isHighlighted {
                    pulseScale = 1.05
                }
            }
            .onChange(of: isHighlighted) { newValue in
                // Сбросить значение при изменении подсветки
                if !newValue {
                    pulseScale = 1.0
                } else {
                    // При активации подсветки установить значение для начала анимации
                    pulseScale = 1.05
                }
            }
    }
}
