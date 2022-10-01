// swift-tools-version: 5.7

import PackageDescription

let package = Package(
        name: "EmojiCantonese",
        products: [
                .executable(name: "emojicantonese", targets: ["EmojiCantonese"])
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
