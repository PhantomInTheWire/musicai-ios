import SwiftUI
import AVFoundation

// Audio Manager class to handle audio playback
class AudioManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    func prepareAudio() {
        guard let audioPath = Bundle.main.path(forResource: "file", ofType: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            audioPlayer?.delegate = self
            totalTime = audioPlayer?.duration ?? 0
        } catch {
            print("Error loading audio:", error.localizedDescription)
        }
    }
    
    func playPauseAudio() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            stopTimer()
        } else {
            player.play()
            startTimer()
        }
        isPlaying = player.isPlaying
    }
    
    func skipForward() {
        guard let player = audioPlayer else { return }
        let newTime = min(player.currentTime + 10, player.duration)
        player.currentTime = newTime
        currentTime = newTime
    }
    
    func skipBackward() {
        guard let player = audioPlayer else { return }
        let newTime = max(player.currentTime - 10, 0)
        player.currentTime = newTime
        currentTime = newTime
    }
    
    // Add seek function
    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        let targetTime = max(0, min(time, totalTime))
        player.currentTime = targetTime
        currentTime = targetTime
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.currentTime = self.audioPlayer?.currentTime ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    func updateVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
}

struct PlayerView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var volume: Double = 0.8
    @State private var showingVolumeSlider = false
    @State private var animateWaveform = false
    @State private var isDragging = false
    @GestureState private var dragOffset: CGFloat = 0
    
    private let gradientColors = [
        Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.5, alpha: 1)), // Deep purple
        Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.3, alpha: 1))  // Darker purple
    ]
    
    var body: some View {
        ZStack {
            // Background with animated circles
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
                
                // Album Art with Reflection
                VStack(spacing: -20) {
                    // Main album art
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 280, height: 280)
                            .blur(radius: 5)
                        
                        Image("file")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    }
                    
                    // Reflection effect
                    ZStack {
                        Image("file")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .white.opacity(0.2)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(1.2)
                            .blur(radius: 0.5)
                    }
                    .frame(height: 100)
                }
                
                // Waveform Visualizer
                HStack(spacing: 4) {
                    ForEach(0..<20) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .bottom, endPoint: .top))
                            .frame(width: 4, height: audioManager.isPlaying ? CGFloat.random(in: 10...50) : 10)
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(index) * 0.05),
                                value: audioManager.isPlaying
                            )
                    }
                }
                .frame(height: 50)
                
                // Song Info
                Text("Royalty (NCS)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, -50)
                Text("Maestro Chives and Neoni")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                // Interactive Progress Bar
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        // Background track
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        isDragging = true
                                        let percentage = min(max(0, value.location.x / geometry.size.width), 1)
                                        audioManager.seek(to: percentage * audioManager.totalTime)
                                    }
                                    .onEnded { _ in
                                        isDragging = false
                                    }
                            )
                        
                        // Progress fill
                        Capsule()
                            .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                            .frame(width: geometry.size.width * CGFloat(audioManager.currentTime / audioManager.totalTime), height: 6)
                        
                        // Drag handle
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                            .position(x: geometry.size.width * CGFloat(audioManager.currentTime / audioManager.totalTime), y: 3)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    .frame(width: 300, height: 12)
                    .contentShape(Rectangle())
                    
                    HStack {
                        Text(formatTime(audioManager.currentTime))
                        Spacer()
                        Text(formatTime(audioManager.totalTime))
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 300)
                }
                
                // Playback Controls
                HStack(spacing: 40) {
                    // Skip Backward Button
                    Button(action: {
                        audioManager.skipBackward()
                    }) {
                        Image(systemName: "gobackward.10")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                    
                    // Play/Pause Button
                    Button(action: {
                        audioManager.playPauseAudio()
                        animateWaveform.toggle()
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 70, height: 70)
                            .background(
                                Circle().fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .shadow(color: .purple.opacity(0.5), radius: 10)
                    }
                    
                    // Skip Forward Button
                    Button(action: {
                        audioManager.skipForward()
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                audioManager.prepareAudio()
                audioManager.updateVolume(Float(volume))
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Preview
#Preview {
    PlayerView()
}
