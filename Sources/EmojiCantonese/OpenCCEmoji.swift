import Foundation

struct OpenCCEmoji: Hashable {

        let name: String
        let emoji: String

        static func generate() {
                let destinationPath: String = "output/emoji.txt"
                let letteredInstances = processLetteredEmoji()
                let emojiInstances = processEmojiFiles()
                let extraEmojiInstances = processExtraEmoji()
                let instances: [OpenCCEmoji] = (letteredInstances + emojiInstances + extraEmojiInstances).uniqued()
                let names: [String] = instances.map(\.name).uniqued().sortedWithUnicodeCodePoint()
                let openCCEmojiLines: [String] = names.map({ name -> String in
                        let emojis = instances.filter({ $0.name == name }).map(\.emoji)
                        let emojiText = emojis.uniqued().joined(separator: String.space)
                        let line = name + String.tab + name + String.space + emojiText
                        return line
                })
                let product: String = openCCEmojiLines.uniqued().joined(separator: String.newLine) + String.newLine
                if FileManager.default.fileExists(atPath: destinationPath) {
                        try? FileManager.default.removeItem(atPath: destinationPath)
                }
                do {
                        try product.write(toFile: destinationPath, atomically: true, encoding: .utf8)
                } catch {
                        print(error.localizedDescription)
                }
        }

        private static func convertLine(_ text: String) -> [OpenCCEmoji] {
                let parts = text.split(separator: "\t").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                guard parts.count == 3 else { fatalError("Bad format: \(text)") }
                let emoji = parts[1].replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").trimmingCharacters(in: .whitespaces)
                let names = parts[2].split(separator: ",").map({ $0.filter({ !$0.isASCII }) }).map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let instances = names.map({ OpenCCEmoji(name: $0, emoji: emoji) })
                return instances
        }

        private static func processEmojiFiles() -> [OpenCCEmoji] {
                let currentPath: String = FileManager.default.currentDirectoryPath
                guard let contents: [String] = try? FileManager.default.contentsOfDirectory(atPath: currentPath) else {
                        fatalError("Filed to fetch contents of path: \(currentPath)")
                }
                let emojiPaths: [String] = contents.filter({ $0.hasPrefix("emoji-") }).sorted()
                let emojiBlocks = emojiPaths.map({ path -> [String] in
                        guard let sourceContent: String = try? String(contentsOfFile: path, encoding: .utf8) else {
                                fatalError("Failed to read content of path: \(path)")
                        }
                        let sourceLines: [String] = sourceContent
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .trimmingCharacters(in: .controlCharacters)
                                .components(separatedBy: .newlines)
                                .filter({ !$0.isEmpty })
                                .map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                                .filter({ !$0.isEmpty })
                                .uniqued()
                        return sourceLines
                })
                let entryLines: [String] = emojiBlocks.flatMap({ $0 }).uniqued()
                let instances: [OpenCCEmoji] = entryLines.map({ convertLine($0) }).flatMap({ $0 }).map({ $0.mappedSkin() })
                return instances
        }
        private static func processExtraEmoji() -> [OpenCCEmoji] {
                let currentPath: String = FileManager.default.currentDirectoryPath
                guard let contents: [String] = try? FileManager.default.contentsOfDirectory(atPath: currentPath) else {
                        fatalError("Filed to fetch contents of path: \(currentPath)")
                }
                guard let path = contents.filter({ $0 == "extra-emoji.txt" }).first else { fatalError("Filed to fetch content of extra-emoji.txt") }
                guard let sourceContent: String = try? String(contentsOfFile: path, encoding: .utf8) else { fatalError("Failed to read content of path: \(path)") }
                let sourceLines: [String] = sourceContent
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .trimmingCharacters(in: .controlCharacters)
                        .components(separatedBy: .newlines)
                        .filter({ !$0.isEmpty })
                        .map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        .filter({ !$0.isEmpty })
                        .uniqued()
                let entries: [OpenCCEmoji] = sourceLines.map({ convertLine($0) }).flatMap({ $0 })
                return entries
        }
}

private extension OpenCCEmoji {
        func mappedSkin() -> OpenCCEmoji {
                if let lightSkinTone = Self.skinMapList[self.emoji] {
                        return OpenCCEmoji(name: self.name, emoji: lightSkinTone)
                } else {
                        return self
                }
        }
        static let skinMapList: [String: String] = {
                let path: String = "light-skin-tone.txt"
                guard let sourceContent: String = try? String(contentsOfFile: path, encoding: .utf8) else { fatalError("Failed to read content of path: \(path)") }
                let sourceLines = sourceContent
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .trimmingCharacters(in: .controlCharacters)
                        .components(separatedBy: .newlines)
                        .filter({ !$0.isEmpty })
                        .map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        .filter({ !$0.isEmpty })
                        .uniqued()
                var mapList: [String: String] = [:]
                _ = sourceLines.map { line in
                        let parts = line.split(separator: "|")
                        guard parts.count == 2 else { fatalError("Bad format: \(line)") }
                        guard let origin = parts[0].split(separator: "{").last?.trimmingCharacters(in: .whitespaces) else { fatalError("Bad format: \(line)") }
                        guard let lightSkin = parts[1].split(separator: "}").first?.trimmingCharacters(in: .whitespaces) else { fatalError("Bad format: \(line)") }
                        mapList[origin] = lightSkin
                }
                return mapList
        }()
}

private extension OpenCCEmoji {
        static func processLetteredEmoji() -> [OpenCCEmoji] {
                let path: String = "lettered-emoji.txt"
                guard let sourceContent: String = try? String(contentsOfFile: path, encoding: .utf8) else { fatalError("Failed to read content of path: \(path)") }
                let sourceLines = sourceContent
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .trimmingCharacters(in: .controlCharacters)
                        .components(separatedBy: .newlines)
                        .filter({ !$0.isEmpty })
                        .map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        .filter({ !$0.isEmpty })
                        .uniqued()
                let entries = sourceLines.map { line -> [OpenCCEmoji] in
                        let parts = line.split(separator: "\t").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        guard parts.count == 3 else { fatalError("Bad format: \(line)") }
                        let emoji = parts[1].replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").trimmingCharacters(in: .whitespaces)
                        let names = parts[2].split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        let instances = names.map({ OpenCCEmoji(name: $0, emoji: emoji) })
                        return instances
                }
                return entries.flatMap({ $0 })
        }
}

extension Array where Element == String {
        func sortedWithUnicodeCodePoint() -> [Element] {
                return self.sorted { (lhs, rhs) -> Bool in
                        if lhs == rhs {
                                fatalError("Duplicated line: \(lhs)")
                        } else if lhs.hasPrefix(rhs) {
                                return false
                        } else if rhs.hasPrefix(lhs) {
                                return true
                        } else {
                                let lhsCodes: [UInt32] = lhs.compactMap(\.unicodeScalars.first?.value)
                                let rhsCodes: [UInt32] = rhs.compactMap(\.unicodeScalars.first?.value)
                                let lhsCount: Int = lhsCodes.count
                                let rhsCount: Int = rhsCodes.count
                                let minLength: Int = Swift.min(lhsCount, rhsCount)
                                var isAscending: Bool = false
                                for index in 0..<minLength {
                                        if lhsCodes[index] < rhsCodes[index] {
                                                isAscending = true
                                                break
                                        } else if lhsCodes[index] > rhsCodes[index] {
                                                isAscending = false
                                                break
                                        } else {
                                                isAscending = false
                                        }
                                }
                                return isAscending
                        }
                }
        }
}
