# Music.ai

A SwiftUI-based music app for iOS and macOS that simulates AI-powered music generation and playback.

## Features
- AI music generation interface with prompts
- Audio playback with controls (play, pause, skip, seek)
- Visual effects including waveforms and progress bars
- Loading animations during music generation

## How the Code Works

### App Structure
- **Music_aiApp.swift**: Main app entry point using SwiftUI's `@main` struct. Launches the app with `ContentView` in a `WindowGroup`.

### Views
- **ContentView.swift**: Root view that displays `GreetingView` in a `NavigationView` for navigation between screens.

- **GreetingView.swift**: Initial screen with:
  - Music logo and title
  - Text input for music prompts
  - "Generate Music" button that triggers navigation to loading screen
  - Consistent gradient background with animated circles

- **LoadingAnimationView.swift**: Loading screen that:
  - Shows animated waveform bars
  - Displays progress circle with percentage
  - Simulates 5-second music generation delay
  - Automatically navigates to player when complete

- **PlayerView.swift**: Main music player with:
  - **AudioManager class**: Handles audio playback using `AVAudioPlayer`
    - Manages play/pause, seeking, volume
    - Updates current time and total duration
    - Uses timer for progress tracking
  - Interactive UI elements:
    - Album art with reflection effect
    - Animated waveform visualizer
    - Draggable progress bar
    - Playback controls (skip 10s, play/pause)
  - Gradient backgrounds with floating circles

### Audio Integration
- Uses `AVFoundation` framework for audio playback
- Loads MP3 file from app bundle
- Supports volume control and seeking
- Implements delegate methods for playback completion

### Design
- Consistent purple/blue gradient theme across all views
- SwiftUI animations for smooth transitions
- Modular component structure for maintainability