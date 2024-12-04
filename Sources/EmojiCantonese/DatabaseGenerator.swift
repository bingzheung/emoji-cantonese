import Foundation

private struct SymbolEntry: CustomStringConvertible, Hashable {
        let category: Int
        let codepoint: String
        let cantonese: String
        let romanization: String
        var description: String {
                let blocks: [String] = [category.description, codepoint, cantonese, romanization]
                return blocks.joined(separator: "\t")
        }
}

// CREATE TABLE symboltable(category INTEGER NOT NULL, codepoint TEXT NOT NULL, cantonese TEXT NOT NULL, romanization TEXT NOT NULL, shortcut INTEGER NOT NULL, ping INTEGER NOT NULL);

struct DatabaseGenerator {

        static func generate() {
                let destinationPath: String = "output/symbol.txt"
                let currentPath: String = FileManager.default.currentDirectoryPath
                guard let contents: [String] = try? FileManager.default.contentsOfDirectory(atPath: currentPath) else {
                        fatalError("Failed to fetch contents of path: \(currentPath)")
                }
                let paths: [String] = contents.filter({ $0.hasPrefix("emoji-") || $0.hasPrefix("symbol-") || $0.hasPrefix("extra-emoji") }).sorted()
                var instances: [SymbolEntry] = []
                for path in paths {
                        let category: Int = categoryCode(of: path)
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
                        let entries = lines.map({ convertLine($0, category: category) }).flatMap({ $0 })
                        instances.append(contentsOf: entries)
                }
                let product = instances.uniqued().map(\.description).joined(separator: "\n") + "\n"
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
                guard path.hasPrefix("emoji-") else { return 9 }
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
                let parts = text.split(separator: "\t").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                guard parts.count == 3 else { fatalError("Bad format: \(text)") }
                let emoji = parts[1].replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").trimmingCharacters(in: .whitespaces)
                let codePointText = emoji.symbolCodePointText
                let names = parts[2].split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                let entryBlocks = names.map { item -> [SymbolEntry] in
                        let blocks = item.split(separator: "(")
                        let word = blocks[0].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters)
                        let romanizations = blocks[1].replacingOccurrences(of: ")", with: "").split(separator: ";").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        let entries = romanizations.map({ SymbolEntry(category: category, codepoint: codePointText, cantonese: word, romanization: $0) })
                        return entries
                }
                return entryBlocks.flatMap({ $0 }).uniqued()
        }
}
