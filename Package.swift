// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SleepPulse",
    defaultLocalization: "es",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SleepPulse",
            targets: ["SleepPulse"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SleepPulse",
            dependencies: [],
            path: "SleepPulse"
        ),
        .testTarget(
            name: "SleepPulseTests",
            dependencies: ["SleepPulse"],
            path: "SleepPulseTests"
        ),
    ]
)
