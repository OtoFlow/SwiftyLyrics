// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyLyrics",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .macCatalyst(.v16),
    ],
    products: [
        .library(name: "SwiftyLyrics", targets: ["SwiftyLyrics"]),
        .library(name: "LyricLabel", targets: ["LyricLabel"]),
    ],
    targets: [
        .target(name: "SwiftyLyrics"),
        .testTarget(
            name: "SwiftyLyricsTests",
            dependencies: ["SwiftyLyrics"],
            resources: [
                .process("Examples"),
            ]
        ),
        .target(name: "LyricLabel", dependencies: ["SwiftyLyrics"]),
    ]
)
