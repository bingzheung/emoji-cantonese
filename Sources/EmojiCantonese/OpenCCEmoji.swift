import Foundation

struct OpenCCEmoji: Hashable {

        let name: String
        let emoji: String

        static func generate() {
                let originalLines: [String] = readEmojiLines()
                let converted = originalLines.map({ convertLine($0) })
                let instances: [OpenCCEmoji] = converted.flatMap({ $0 }).uniqued()
                let simplifiedInstances = instances.map({ OpenCCEmoji(name: $0.name.simplified(), emoji: $0.emoji) })
                let allInstances: [OpenCCEmoji] = (instances + simplifiedInstances).uniqued()
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
                // U+1F34F\t{ 🍏 }\t[ 青蘋果, 蘋果 ]
                // 0: U+1F34F
                // 1: { 🍏 }
                // 2: [ 青蘋果, 蘋果 ]
                let parts = text.split(separator: "\t")
                guard parts.count == 3 else { fatalError("Bad format: \(text)") }
                let emoji = parts[1].replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters)
                let names = parts[2].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let itemInstances = names.map { name -> OpenCCEmoji in
                        let convertedName: String = name.replacingOccurrences(of: "㔹", with: "叻")
                                .replacingOccurrences(of: "睏", with: "瞓")
                                .replacingOccurrences(of: "惗", with: "諗")
                                .replacingOccurrences(of: "癐", with: "攰")
                        let instance: OpenCCEmoji = OpenCCEmoji(name: convertedName, emoji: emoji)
                        return instance
                }
                return itemInstances
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
