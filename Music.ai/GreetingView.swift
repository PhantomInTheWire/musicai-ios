import SwiftUI

struct GreetingView: View {
    @State private var musicPrompt: String = ""
    @State private var shouldShowLoadingAnimation = false
    
    // Consistent gradient colors with PlayerView
    private let gradientColors = [
        Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.5, alpha: 1)), // Deep purple
        Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.3, alpha: 1))  // Darker purple
    ]
    
    var body: some View {
        ZStack {
            // Matching background gradient
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
            
            VStack(spacing: 30) {
                Spacer()
                
                // Generic music logo at the top
                Image(systemName: "music.note.house.fill") // Using a system symbol
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Title with gradient overlay
                Text("Music.AI")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple, Color.teal]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Subtitle
                Text("AI-powered music generation")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 10)
                
                // Input field with shadow and blurred background
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("", text: $musicPrompt)
                        .foregroundColor(.white.opacity(0.9))
                        .padding()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                        .blur(radius: 2)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: -5, y: 5)
                        .shadow(color: .white.opacity(0.2), radius: 10, x: 5, y: -5)
                )
                .padding(.horizontal)
                
                // Generate button with gradient and consistent design
                Button(action: {
                    shouldShowLoadingAnimation = true
                }) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 20, weight: .bold))
                        Text("Generate Music")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 40)
            
            // Navigation to LoadingAnimationView
            NavigationLink(
                destination: LoadingAnimationView(topic: musicPrompt, genre: "pop"),
                isActive: $shouldShowLoadingAnimation
            ) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }
}

// Preview
#Preview {
    GreetingView()
}
