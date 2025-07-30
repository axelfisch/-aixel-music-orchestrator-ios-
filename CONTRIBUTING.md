# Contributing to AiXel Music Orchestrator

We welcome contributions to the AiXel Music Orchestrator project! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the Repository**
   - Fork the project on GitHub
   - Clone your fork locally
   ```bash
   git clone https://github.com/yourusername/aixel-music-orchestrator-ios.git
   cd aixel-music-orchestrator-ios
   ```

2. **Set Up Development Environment**
   - Xcode 15.0 or later
   - iOS 15.0+ deployment target
   - Swift 5.0+
   - Python 3.8+ for orchestration engine

## Development Guidelines

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain consistent indentation (4 spaces)
- Add documentation for public APIs
- Use meaningful variable and function names

### Commit Messages

Use clear and descriptive commit messages:
```
feat: add new chord progression algorithm
fix: resolve audio latency issue on older devices
docs: update README with installation instructions
test: add unit tests for composition generation
```

### Branch Naming

- `feature/description` for new features
- `fix/description` for bug fixes
- `docs/description` for documentation updates
- `test/description` for test additions

## Types of Contributions

### Bug Reports

When reporting bugs, please include:
- iOS version and device model
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots or recordings if applicable
- Console logs if relevant

### Feature Requests

For new features, please provide:
- Clear description of the feature
- Use case and benefits
- Proposed implementation approach
- Any relevant mockups or examples

### Code Contributions

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Write clean, well-documented code
   - Add tests for new functionality
   - Ensure existing tests pass
   - Update documentation as needed

3. **Test Your Changes**
   ```bash
   # Run unit tests
   xcodebuild test -scheme AiXelMusicOrchestrator -destination 'platform=iOS Simulator,name=iPhone 15'
   
   # Test on physical device if possible
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Pull Request Process

1. **Before Submitting**
   - Ensure your code follows the style guidelines
   - Add or update tests as necessary
   - Update documentation
   - Verify all tests pass

2. **Pull Request Description**
   - Clearly describe what your PR does
   - Reference any related issues
   - Include screenshots for UI changes
   - List any breaking changes

3. **Review Process**
   - Maintainers will review your PR
   - Address any feedback or requested changes
   - Once approved, your PR will be merged

## Development Setup

### Prerequisites

```bash
# Install Xcode from App Store
# Install Python dependencies
pip3 install music21 numpy scipy

# Install AudioKit dependencies (handled by Swift Package Manager)
```

### Building the Project

1. Open `AiXelMusicOrchestrator.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘+R)

### Running Tests

```bash
# Command line
xcodebuild test -scheme AiXelMusicOrchestrator -destination 'platform=iOS Simulator,name=iPhone 15'

# Or use Xcode Test Navigator (⌘+6)
```

## Code Areas

### Audio Engine (`Audio/`)
- AudioKit integration
- Real-time audio processing
- Instrument engines
- Performance optimization

### Composition Engine (`ViewModels/`, `Resources/`)
- AI composition algorithms
- Music theory implementation
- Python bridge integration
- Axel Fisch style implementation

### User Interface (`Views/`)
- SwiftUI components
- Professional audio aesthetics
- Accessibility support
- Responsive design

### Export System (`Utils/`)
- MIDI file generation
- MusicXML export
- Audio rendering
- File format support

## Musical Contributions

We especially welcome contributions in:

- **Music Theory**: Improvements to chord progression algorithms
- **Orchestration**: Enhanced voice leading and arrangement techniques
- **Audio Processing**: Performance optimizations and new effects
- **User Experience**: Interface improvements and accessibility features

## Questions and Support

- **GitHub Issues**: For bug reports and feature requests
- **Discussions**: For general questions and ideas
- **Email**: For private inquiries to the maintainers

## Recognition

Contributors will be recognized in:
- README.md contributors section
- App Store credits (for significant contributions)
- Release notes for their contributions

## License

By contributing to AiXel Music Orchestrator, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to AiXel Music Orchestrator! 🎵

