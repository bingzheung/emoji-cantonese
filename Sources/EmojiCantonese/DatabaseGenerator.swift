import Foundation

private struct SymbolEntry: CustomStringConvertible, Hashable {
        let category: Int
        let codepoint: String
        let cantonese: String
        let romanization: String
        let shortcut: Int
        let ping: Int
        var description: String {
                let blocks: [String] = [category.description, codepoint, cantonese, romanization, shortcut.description, ping.description]
                return blocks.joined(separator: "\t")
        }
}

// CREATE TABLE symboltable(category INTEGER NOT NULL, codepoint TEXT NOT NULL, cantonese TEXT NOT NULL, romanization TEXT NOT NULL, shortcut INTEGER NOT NULL, ping INTEGER NOT NULL);

struct DatabaseGenerator {

        static func generate() {
                let currentPath: String = FileManager.default.currentDirectoryPath
                guard let contents: [String] = try? FileManager.default.contentsOfDirectory(atPath: currentPath) else {
                        fatalError("Failed to fetch contents of path: \(currentPath)")
                }
                let paths: [String] = contents.filter({ $0.hasPrefix("emoji-") || $0.hasPrefix("symbol-") }).sorted()
                var instances: [SymbolEntry] = []
                for path in paths {
                        let category: Int = categoryCode(of: path)
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
                        let entries = lines.map({ convertLine($0, category: category) }).flatMap({ $0 })
                        instances.append(contentsOf: entries)
                }
                let product = instances.uniqued().map(\.description).joined(separator: "\n") + "\n"
                let destinationPath: String = "symbol.txt"
                if FileManager.default.fileExists(atPath: destinationPath) {
                        try? FileManager.default.removeItem(atPath: destinationPath)
                }
                do {
                        try product.write(toFile: destinationPath, atomically: true, encoding: .utf8)
                } catch {
                        print(error.localizedDescription)
                }
        }
        private static func categoryCode(of path: String) -> Int {
                guard !path.hasPrefix("symbol-") else { return 9 }
                guard let first = path.dropFirst(6).first else { fatalError("bad path: \(path)") }
                switch first {
                case "1":
                        return 1
                case "2":
                        return 2
                case "3":
                        return 3
                case "4":
                        return 4
                case "5":
                        return 5
                case "6":
                        return 6
                case "7":
                        return 7
                case "8":
                        return 8
                default:
                        fatalError("bad path: \(path)")
                }
        }

        private static func convertLine(_ text: String, category: Int) -> [SymbolEntry] {
                // { 🍏 }\t青蘋果(jyutping1; jyutping2), 蘋果(jyutping)
                // 0: { 🍏 }
                // 2: 青蘋果(jyutping1; jyutping2), 蘋果(jyutping)
                let parts = text.split(separator: "\t")
                guard parts.count == 2 else { fatalError("Bad format: \(text)") }
                let emoji = parts[0].replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").trimmingCharacters(in: .whitespaces)
                let codePointText = emoji.symbolCodePointText
                let names = parts[1].split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let entryBlocks = names.map { item -> [SymbolEntry] in
                        let blocks = item.split(separator: "(")
                        let word = blocks[0].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters)
                        let romanizations = blocks[1].replacingOccurrences(of: ")", with: "").split(separator: ";").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        let entries = romanizations.map { romanization -> SymbolEntry in
                                let shortcut = shortcutCode(of: romanization)
                                let ping = romanization.removedSpacesTones().hash
                                let entry = SymbolEntry(category: category, codepoint: codePointText, cantonese: word, romanization: romanization, shortcut: shortcut, ping: ping)
                                return entry
                        }
                        return entries
                }
                return entryBlocks.flatMap({ $0 }).uniqued()
        }
        private static func shortcutCode(of text: String) -> Int {
                let syllables = text.split(separator: " ").filter({ !$0.isEmpty })
                let anchors = syllables.map(\.first).compactMap({ $0 })
                let anchorsText = String(anchors)
                return anchorsText.hash
        }
}
