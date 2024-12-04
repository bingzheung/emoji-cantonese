// swift-tools-version: 6.0

import PackageDescription

let package = Package(
        name: "EmojiCantonese",
        platforms: [.macOS(.v15)],
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
