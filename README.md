# AiXel Music Orchestrator

A sophisticated iOS application for generating and orchestrating jazz-pop compositions in the style of Axel Fisch, featuring AI-powered chord progressions, 8-voice orchestration, and professional audio export capabilities.

## Features

### 🎵 Composition Generation
- **AI-Powered Chord Progressions**: Generate sophisticated jazz-pop chord progressions using Axel Fisch's harmonic vocabulary
- **AABA Form Structure**: Classic 32-bar song form with intelligent voice leading
- **Multiple Keys**: Support for all major and minor keys with modal interchange
- **Style Variations**: Jazz-pop, contemporary, and fusion styles

### 🎼 8-Voice Orchestration
- **Professional Instrumentation**: Flute, Piano, Violin I & II, Viola I & II, Cello, Bass
- **Intelligent Voicing**: Automatic voice leading and orchestration based on jazz principles
- **Real-time Audio**: High-quality AudioKit-powered playback engine
- **Individual Control**: Volume, reverb, and mute controls for each instrument

### 🎛️ Advanced Mixer
- **Professional Interface**: 8-channel mixer with individual controls
- **Real-time Processing**: Live audio effects and parameter adjustment
- **Visual Feedback**: Professional audio equipment aesthetic
- **Touch Optimized**: Designed for iOS touch interaction

### 📤 Export Capabilities
- **MIDI Export**: Standard MIDI files compatible with all DAWs
- **MusicXML Export**: Professional notation software compatibility
- **Audio Export**: High-quality WAV files for sharing and production
- **PDF Scores**: Generate printable sheet music

## Technical Architecture

### Core Technologies
- **Swift 5.0** with SwiftUI for modern iOS development
- **AudioKit** for professional audio processing and playback
- **Python Integration** for advanced music theory and composition algorithms
- **Core Audio** for low-latency audio performance

### Key Components

#### Audio Engine
```swift
// High-performance audio processing
AudioManager: Real-time audio playback and mixing
InstrumentEngine: Individual instrument audio processing
AudioKit Integration: Professional audio framework
```

#### Composition Engine
```swift
// AI-powered music generation
OrchestrationManager: Composition and orchestration logic
PythonBridge: Integration with music theory algorithms
MusicalModels: Core data structures for musical concepts
```

#### User Interface
```swift
// Modern SwiftUI interface
ContentView: Main application interface
MixerView: Professional 8-channel mixer
CompositionView: Composition generation controls
ExportView: File export and sharing
```

## Installation and Setup

### Prerequisites
- **Xcode 15.0+** with iOS 15.0+ deployment target
- **macOS 13.0+** for development
- **Apple Developer Account** for device testing and App Store submission
- **Python 3.8+** for orchestration engine

### Dependencies
The app uses the following key dependencies:
- AudioKit (audio processing)
- AudioKitUI (audio interface components)
- MIDIKit (MIDI file generation)
- PythonKit (Python integration)

### Build Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/axelfisch/aixel-music-orchestrator.git
   cd aixel-music-orchestrator
   ```

2. **Open in Xcode**
   ```bash
   open AiXelMusicOrchestrator.xcodeproj
   ```

3. **Configure Dependencies**
   - Add AudioKit via Swift Package Manager
   - Configure Python environment for orchestration engine
   - Set up code signing with your Apple Developer account

4. **Build and Run**
   - Select target device or simulator
   - Build and run the project (⌘+R)

### Configuration

#### Audio Settings
```swift
// Configure audio engine in AudioManager
let audioEngine = AudioEngine()
audioEngine.settings.bufferLength = .medium
audioEngine.settings.sampleRate = 44100
```

#### Python Environment
```python
# Install required Python packages
pip install music21 numpy scipy
```

## Usage Guide

### Generating Compositions

1. **Select Parameters**
   - Choose key (C, Eb, F#, etc.)
   - Select form (AABA)
   - Pick style (Jazz Pop)
   - Set tempo (60-200 BPM)

2. **Generate Composition**
   - Tap "Generate Composition" button
   - Wait for AI processing (2-5 seconds)
   - Review generated chord progression

3. **Playback and Mixing**
   - Use playback controls to start/stop
   - Adjust individual instrument levels
   - Apply reverb and effects

### Exporting Your Work

1. **MIDI Export**
   - Navigate to Export tab
   - Select "Export MIDI"
   - Share or save to Files app

2. **Audio Export**
   - Choose "Export Audio"
   - Select quality settings
   - Generate WAV file

3. **Sheet Music**
   - Select "Export MusicXML"
   - Open in notation software
   - Print or further edit

## Development

### Project Structure
```
AiXelMusicOrchestrator/
├── AiXelMusicOrchestrator/
│   ├── Views/                 # SwiftUI interface components
│   ├── Models/                # Core data models
│   ├── ViewModels/            # MVVM view models
│   ├── Audio/                 # Audio processing engine
│   ├── Utils/                 # Utility classes and extensions
│   └── Resources/             # Python scripts and assets
├── AiXelMusicOrchestratorTests/  # Unit and integration tests
├── Assets/                    # App icons and visual assets
└── Documentation/             # Technical documentation
```

### Key Classes

#### OrchestrationManager
The central coordinator for composition generation and orchestration.
```swift
class OrchestrationManager: ObservableObject {
    func generateComposition(parameters: CompositionParameters) async -> Composition
    func generateVoicing(for chord: Chord) -> Voicing?
    func applyAxelFischStyle(to progression: [Chord]) -> [Chord]
}
```

#### AudioManager
Handles all audio playback and real-time processing.
```swift
class AudioManager: ObservableObject {
    func initializeAudioEngine() -> Bool
    func loadComposition(_ composition: Composition)
    func setVolume(_ volume: Float, for instrument: InstrumentType)
    func setReverb(_ reverb: Float, for instrument: InstrumentType)
}
```

### Testing

#### Running Tests
```bash
# Run all tests
xcodebuild test -scheme AiXelMusicOrchestrator -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -scheme AiXelMusicOrchestrator -only-testing:AiXelMusicOrchestratorTests
```

#### Test Coverage
- Unit tests for composition generation
- Integration tests for audio playback
- Performance tests for optimization
- UI tests for user interaction

### Performance Optimization

See [PERFORMANCE_OPTIMIZATION.md](PERFORMANCE_OPTIMIZATION.md) for detailed performance guidelines and optimization strategies.

Key performance targets:
- Audio latency: < 20ms
- UI frame rate: 60fps
- Memory usage: < 400MB
- Composition generation: < 5s

## Axel Fisch Musical Style

The app implements the sophisticated harmonic vocabulary and orchestration techniques of Axel Fisch:

### Harmonic Features
- **Extended Chords**: maj9, min13, sus(b9), 7(#11)
- **Modal Interchange**: Borrowing from parallel modes
- **Chromatic Voice Leading**: Smooth bass lines and inner voices
- **Tritone Substitutions**: Advanced harmonic substitutions

### Orchestration Principles
- **Balanced Voicing**: Optimal distribution across 8 voices
- **Idiomatic Writing**: Each instrument plays in its natural range
- **Textural Variety**: Dynamic interplay between instruments
- **Jazz Harmony**: Sophisticated chord voicings and progressions

## Contributing

We welcome contributions to improve the AiXel Music Orchestrator. Please follow these guidelines:

1. **Fork the Repository**
2. **Create Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit Changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push to Branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open Pull Request**

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Include unit tests for new features
- Document public APIs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Axel Fisch** - Musical style and harmonic concepts
- **AudioKit Team** - Professional audio framework
- **Swift Community** - Language and ecosystem support
- **Music Theory Contributors** - Academic research and resources

## Support

For support, feature requests, or bug reports:

- **GitHub Issues**: [Create an issue](https://github.com/axelfisch/aixel-music-orchestrator/issues)
- **Email**: support@aixelmusic.com
- **Documentation**: [Wiki](https://github.com/axelfisch/aixel-music-orchestrator/wiki)

## Roadmap

### Version 1.1
- [ ] Additional musical styles
- [ ] Custom chord progressions
- [ ] Advanced export options
- [ ] iPad-optimized interface

### Version 1.2
- [ ] Real-time collaboration
- [ ] Cloud composition storage
- [ ] Advanced audio effects
- [ ] MIDI controller support

### Version 2.0
- [ ] Machine learning composition
- [ ] Vocal melody generation
- [ ] Multi-track recording
- [ ] Professional mixing tools

---

**AiXel Music Orchestrator** - Bringing sophisticated jazz-pop orchestration to iOS.

*Built with ❤️ for musicians and composers.*

