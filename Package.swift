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
        // AudioKit for audio processing and synthesis (consolidated)
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0"),
        // MIDI processing
        .package(url: "https://github.com/AudioKit/MIDIKit.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "AiXelMusicOrchestrator",
            dependencies: [
                .product(name: "AudioKit", package: "AudioKit"),
                // Remove extra AudioKit subpackages to reduce binary size
                .product(name: "MIDIKit", package: "MIDIKit"),
                .product(name: "AudioKit", package: "AudioKit"),
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

