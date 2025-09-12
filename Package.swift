// swift-tools-version: 6.2

import PackageDescription

let package = Package(
        name: "EmojiCantonese",
        platforms: [.macOS(.v26)],
        products: [
                .executable(name: "EmojiCantonese", targets: ["EmojiCantonese"])
        ],
        targets: [
                .executableTarget(
                        name: "EmojiCantonese"
                ),
                .testTarget(
                        name: "EmojiCantoneseTests",
                        dependencies: ["EmojiCantonese"]
                )
        ]
)
