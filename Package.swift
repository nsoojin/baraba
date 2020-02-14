// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Baraba",
    platforms: [
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "Baraba",
            targets: ["Baraba"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Baraba",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "BarabaTests",
            dependencies: ["Baraba"],
            path: "Tests"
        ),
    ]
)
