import Foundation

extension Array where Element: Hashable {

        /// Returns a new Array with the unique elements of this Array, in the order of the first occurrence of each unique element.
        /// - Returns: A new Array with only the unique elements of this Array.
        /// - Complexity: O(*n*), where *n* is the length of the Array.
        public func uniqued() -> [Element] {
                var set: Set<Element> = Set<Element>()
                return filter { set.insert($0).inserted }
        }


        /// Safely access element by index
        /// - Parameter index: Index
        /// - Returns: An Element if index is compatible, otherwise nil.
        public func fetch(_ index: Int) -> Element? {
                let isSafe: Bool = index >= 0 && index < self.count
                guard isSafe else { return nil }
                return self[index]
        }
}

struct EmojiItem: Hashable {
        let name: String
        let emoji: String
}

@main
public struct EmojiCantonese {

        public static func main() {
                let originalLines: [String] = accessFiles()
                let converted = originalLines.map({ convertLine(text: $0) })
                let emojiInstances: [EmojiItem] = converted.flatMap({ $0 }).uniqued()
                let simplifiedInstances = emojiInstances.map { item -> EmojiItem in
                        let simplifiedName: String = convertT2S(from: item.name)
                        return EmojiItem(name: simplifiedName, emoji: item.emoji)
                }
                let emojiWordTXTInstances = processEmojiWordTXT()
                let combinedInstances: [EmojiItem] = (emojiInstances + simplifiedInstances + emojiWordTXTInstances).uniqued()
                let names = combinedInstances.map { $0.name }
                let items = names.map { name -> String in
                        let emojis = combinedInstances.filter({ $0.name == name }).map({ $0.emoji })
                        let emojiText = emojis.uniqued().joined(separator: " ")
                        let line = name + "\t" + name + " " + emojiText
                        return line
                }
                let product: String = items.uniqued().joined(separator: "\n") + "\n"
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

        private static func convertLine(text: String) -> [EmojiItem] {
                guard !text.isEmpty else { return [] }
                // original text: U+1F34F\t{ 🍏 }\t[ 青蘋果, 蘋果 ]
                // 0: U+1F34F
                // 1: { 🍏 }
                // 2: [ 青蘋果, 蘋果 ]
                let parts = text.split(separator: "\t")
                let emoji = parts[1].replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters)
                let names = parts[2].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").split(separator: ",")
                let trimmedNames: [String] = names.map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let itemInstances = trimmedNames.map { name -> EmojiItem in
                        let convertedName: String = name.replacingOccurrences(of: "㔹", with: "叻")
                                .replacingOccurrences(of: "睏", with: "瞓")
                                .replacingOccurrences(of: "惗", with: "諗")
                                .replacingOccurrences(of: "癐", with: "攰")
                        let instance: EmojiItem = EmojiItem(name: convertedName, emoji: emoji)
                        return instance
                }
                return itemInstances
        }

        private static func accessFiles() -> [String] {
                let currentPath: String = FileManager.default.currentDirectoryPath
                let contents: [String] = try! FileManager.default.contentsOfDirectory(atPath: currentPath)
                let emojiPaths: [String] = contents.filter({ $0.hasPrefix("emoji-") }).sorted()
                let texts = emojiPaths.map({ path -> [String] in
                        let read: String = try! String(contentsOfFile: path)
                        let lines: [String] = read.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                        let trimmed: [String] = lines.map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        return trimmed
                })
                let lines: [String] = texts.flatMap({ $0 })
                return lines
        }

        private static func processEmojiWordTXT() -> [EmojiItem] {
                guard let content = try? String(contentsOfFile: "emoji_word.txt") else { return [] }
                let sourceLines: [String] = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let emojiItems = sourceLines.map { line -> [EmojiItem] in
                        let parts = line.split(separator: "\t")
                        let name = parts[0]
                        let emojis = parts[1].split(separator: " ").dropFirst()
                        let items = emojis.map { emoji -> EmojiItem in
                                return EmojiItem(name: String(name), emoji: String(emoji))
                        }
                        return items
                }
                return emojiItems.flatMap({ $0 }).uniqued()
        }

        /// Convert traditional characters to simplified
        /// - Parameter text: Traditional characters
        /// - Returns: Simplified characters
        private static func convertT2S(from text: String) -> String {
                let transformed: String? = text.applyingTransform(StringTransform("Simplified-Traditional"), reverse: true)
                return transformed ?? text
        }
}
