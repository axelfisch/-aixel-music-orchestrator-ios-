// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StringsOrchestrator",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "StringsOrchestrator",
            targets: ["StringsOrchestrator"]),
    ],
    targets: [
        .target(
            name: "StringsOrchestrator",
            dependencies: [],
            path: "StringsOrchestrator"
        ),
    ]
)