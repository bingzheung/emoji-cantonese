import Foundation

struct OpenCCEmoji: Hashable {

        let name: String
        let emoji: String

        static func generate() {
                let destinationPath: String = "output/emoji.txt"
                let originalLines: [String] = readEmojiLines()
                let converted = originalLines.map({ convertLine($0) })
                let instances: [OpenCCEmoji] = converted.flatMap({ $0 }).uniqued()
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
                let names = parts[2].split(separator: ",").map({ $0.filter({ !$0.isASCII }) }).map({ $0 .trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let instances = names.map({ OpenCCEmoji(name: $0, emoji: emoji) })
                return instances
        }

        private static func readEmojiLines() -> [String] {
                let currentPath: String = FileManager.default.currentDirectoryPath
                guard let contents: [String] = try? FileManager.default.contentsOfDirectory(atPath: currentPath) else {
                        fatalError("Filed to fetch contents of path: \(currentPath)")
                }
                let emojiPaths: [String] = contents.filter({ $0.hasPrefix("emoji-") || $0.hasPrefix("extra-emoji") }).sorted()
                let blocks = emojiPaths.map({ path -> [String] in
                        guard let content: String = try? String(contentsOfFile: path, encoding: .utf8) else {
                                fatalError("Failed to read content of path: \(path)")
                        }
                        let lines: [String] = content
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .trimmingCharacters(in: .controlCharacters)
                                .components(separatedBy: .newlines)
                                .filter({ !$0.isEmpty })
                                .map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                                .filter({ !$0.isEmpty })
                                .uniqued()
                        return lines
                })
                let lines: [String] = blocks.flatMap({ $0 }).uniqued()
                return lines
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
