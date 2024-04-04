// swift-tools-version: 5.10

import PackageDescription

let package = Package(
        name: "EmojiCantonese",
        platforms: [.macOS(.v14)],
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
