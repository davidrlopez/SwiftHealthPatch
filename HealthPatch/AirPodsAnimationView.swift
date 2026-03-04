import SwiftUI

struct AirPodsAnimationView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // AirPods case with 3D rotation
            AirPodsCaseView()
                .scaleEffect(1.5) // Make it much bigger
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0)
                )
                .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct AirPodsCaseView: View {
    var body: some View {
        ZStack {
            // Main case body
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            
            // AirPods inside
            HStack(spacing: 8) {
                // Left AirPod
                Circle()
                    .fill(Color.white)
                    .frame(width: 25, height: 25)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Right AirPod
                Circle()
                    .fill(Color.white)
                    .frame(width: 25, height: 25)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Status light
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
                .offset(x: 0, y: -25)
        }
    }
}

#Preview {
    AirPodsAnimationView()
} 