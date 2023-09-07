// swift-tools-version: 5.9

import PackageDescription

let package = Package(
        name: "EmojiCantonese",
        platforms: [.macOS(.v13)],
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
