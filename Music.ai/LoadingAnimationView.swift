import SwiftUI

struct LoadingAnimationView: View {
    @State private var isAnimating = false
    @State private var shouldNavigateToPlayer = false
    @State private var progress: CGFloat = 0
    @State private var showProgressText = false
    @State private var displayProgress = 0

    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    private let gradientColors = [
        Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.5, alpha: 1)),
        Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.3, alpha: 1))
    ]
    
    var body: some View {
        ZStack {
            // Background gradient with animated circles matching PlayerView
            RadialGradient(
                gradient: Gradient(colors: gradientColors),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            .overlay(
                GeometryReader { geometry in
                    ForEach(0..<20) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 50...150))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .blur(radius: 20)
                    }
                }
            )
            
            VStack(spacing: 40) {
                // Animated Waveform with matching gradient and smoother animation
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .bottom, endPoint: .top)
                            )
                            .frame(width: 12, height: 40)
                            .scaleEffect(y: isAnimating ? 0.4 : 1)
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(index) * 0.1),
                                value: isAnimating
                            )
                    }
                }
                
                // Progress Circle with gradient to match PlayerView
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .foregroundColor(Color.white.opacity(0.2))
                    
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                    
                    if showProgressText {
                        Text("\(displayProgress)%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .transition(.opacity)
                            .animation(.none, value: displayProgress)
                    }
                }
                .frame(width: 200, height: 200)
                
                Text("Generating your music...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            NavigationLink(
                destination: PlayerView(),
                isActive: $shouldNavigateToPlayer,
                label: { EmptyView() }
            )
        }
        .onAppear {
            startAnimations()
        }
        .onReceive(timer) { _ in
            updateProgress()
        }
    }
    
    private func startAnimations() {
        isAnimating = true
        withAnimation(.easeIn(duration: 0.5)) {
            showProgressText = true
        }
        Task {
            await generateMusic()
        }
    }
    
    private func updateProgress() {
        if displayProgress < 100 && !shouldNavigateToPlayer {
            let newProgress = min(progress + 0.005, 1.0)
            progress = newProgress
            displayProgress = Int(newProgress * 100)
        }
    }
    
    private func generateMusic() async {
        do {
            try await Task.sleep(nanoseconds: 5_000_000_000)
            DispatchQueue.main.async {
                shouldNavigateToPlayer = true
            }
        } catch {
            print("Error generating music: \(error)")
        }
    }
}

// Preview
#Preview {
    LoadingAnimationView()
}
