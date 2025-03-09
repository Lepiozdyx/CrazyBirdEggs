import SwiftUI

struct AnimatedRowView<Content: View>: View {
    let isHighlighted: Bool
    let content: Content
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var isAnimating: Bool = false
    @State private var animationTask: Task<Void, Never>? = nil
    
    init(isHighlighted: Bool, @ViewBuilder content: () -> Content) {
        self.isHighlighted = isHighlighted
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHighlighted ? .yellow.opacity(0.7) : .clear)
                    .scaleEffect(pulseScale)
            )
            .onChange(of: isHighlighted) { newValue in
                animationTask?.cancel()
                
                if newValue {
                    startPulseAnimation()
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        pulseScale = 1.0
                    }
                    isAnimating = false
                }
            }
            .onAppear {
                if isHighlighted {
                    startPulseAnimation()
                }
            }
            .onDisappear {
                animationTask?.cancel()
                animationTask = nil
                isAnimating = false
            }
    }
    
    private func startPulseAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        animationTask = Task {
            for _ in 0..<4 {
                if Task.isCancelled { break }
                
                await animatePulse(to: 1.05, duration: 0.3)
                if Task.isCancelled { break }
                
                await animatePulse(to: 1.0, duration: 0.3)
                if Task.isCancelled { break }
            }
            
            if !Task.isCancelled {
                await MainActor.run {
                    isAnimating = false
                }
            }
        }
    }
    
    @MainActor
    private func animatePulse(to value: CGFloat, duration: Double) async {
        withAnimation(.easeInOut(duration: duration)) {
            pulseScale = value
        }
        
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}
