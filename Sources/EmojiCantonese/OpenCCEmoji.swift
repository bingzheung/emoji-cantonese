import Foundation

struct OpenCCEmoji: Hashable {

        let name: String
        let emoji: String

        static func generate() {
                let originalLines: [String] = readEmojiLines()
                let converted = originalLines.map({ convertLine($0) })
                let instances: [OpenCCEmoji] = converted.flatMap({ $0 }).uniqued()
                // let simplifiedInstances = instances.map({ OpenCCEmoji(name: $0.name.simplified(), emoji: $0.emoji) })
                let allInstances: [OpenCCEmoji] = instances // (instances + simplifiedInstances).uniqued()
                let names: [String] = allInstances.map(\.name).uniqued()
                let openCCEmojiLines: [String] = names.map({ name -> String in
                        let emojis = allInstances.filter({ $0.name == name }).map({ $0.emoji })
                        let emojiText = emojis.uniqued().joined(separator: " ")
                        let line = name + "\t" + name + " " + emojiText
                        return line
                })
                let product: String = openCCEmojiLines.uniqued().joined(separator: "\n") + "\n"
                let destinationPath: String = "opencc/emoji_cantonese.txt"
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
                let emojiPaths: [String] = contents.filter({ $0.hasPrefix("emoji-") }).sorted()
                let blocks = emojiPaths.map({ path -> [String] in
                        guard let content: String = try? String(contentsOfFile: path) else {
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
