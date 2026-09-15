// swift-tools-version: 6.4

import PackageDescription

let package = Package(
        name: "EmojiCantonese",
        platforms: [.macOS(.v27)],
        products: [
                .executable(name: "EmojiCantonese", targets: ["EmojiCantonese"])
        ],
        targets: [
                .executableTarget(name: "EmojiCantonese")
        ],
        swiftLanguageModes: [.v6]
)
