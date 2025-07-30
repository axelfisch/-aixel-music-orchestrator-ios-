// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AiXelMusicOrchestrator",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AiXelMusicOrchestrator",
            targets: ["AiXelMusicOrchestrator"]
        ),
    ],
    dependencies: [
        // AudioKit for audio processing and synthesis
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/AudioKitEX.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/DunneAudioKit.git", from: "5.6.0"),
        
        // MIDI processing
        .package(url: "https://github.com/AudioKit/MIDIKit.git", from: "0.9.0"),
        
        // Additional audio utilities
        .package(url: "https://github.com/AudioKit/Tonic.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AiXelMusicOrchestrator",
            dependencies: [
                .product(name: "AudioKit", package: "AudioKit"),
                .product(name: "SoundpipeAudioKit", package: "SoundpipeAudioKit"),
                .product(name: "AudioKitEX", package: "AudioKitEX"),
                .product(name: "DunneAudioKit", package: "DunneAudioKit"),
                .product(name: "MIDIKit", package: "MIDIKit"),
                .product(name: "Tonic", package: "Tonic"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AiXelMusicOrchestratorTests",
            dependencies: ["AiXelMusicOrchestrator"]
        ),
    ]
)

