import Foundation

private struct JyutpingEntry: CustomStringConvertible, Hashable {
        let word: String
        let romanization: String
        var description: String {
                return word + "\t" + romanization
        }
}

struct JyutpingGenerator {

        static func generate() {
                let originalLines: [String] = readFileLines()
                let converted = originalLines.map({ convertLine($0) })
                let entries: [JyutpingEntry] = converted.flatMap({ $0 }).uniqued()
                let product: String = entries.map(\.description).joined(separator: "\n") + "\n"
                let destinationPath: String = "EmojiJyutping.txt"
                if FileManager.default.fileExists(atPath: destinationPath) {
                        try? FileManager.default.removeItem(atPath: destinationPath)
                }
                do {
                        try product.write(toFile: destinationPath, atomically: true, encoding: .utf8)
                } catch {
                        print(error.localizedDescription)
                }
        }

        private static func convertLine(_ text: String) -> [JyutpingEntry] {
                let parts = text.split(separator: "\t").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                guard parts.count == 3 else { fatalError("Bad format: \(text)") }
                let names = parts[2].split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let entryBlocks = names.map { item -> [JyutpingEntry] in
                        let blocks = item.split(separator: "(")
                        let word = blocks[0].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters)
                        let romanizations = blocks[1].replacingOccurrences(of: ")", with: "").split(separator: ";").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        let entries = romanizations.map({ JyutpingEntry(word: word, romanization: $0) })
                        return entries
                }
                return entryBlocks.flatMap({ $0 }).uniqued()
        }

        private static func readFileLines() -> [String] {
                let currentPath: String = FileManager.default.currentDirectoryPath
                guard let contents: [String] = try? FileManager.default.contentsOfDirectory(atPath: currentPath) else {
                        fatalError("Failed to fetch contents of path: \(currentPath)")
                }
                let paths: [String] = contents.filter({ $0.hasPrefix("emoji-") || $0.hasPrefix("symbol-") || $0.hasPrefix("extra-emoji") }).sorted()
                let blocks = paths.map({ path -> [String] in
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
