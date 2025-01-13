import Foundation

private struct JyutpingEntry: CustomStringConvertible, Hashable, Comparable {
        let word: String
        let romanization: String
        var description: String {
                return word + String.tab + romanization
        }
        private static let englishLocale: Locale = Locale(identifier: "en")
        static func < (lhs: JyutpingEntry, rhs: JyutpingEntry) -> Bool {
                let romanizationCompare = lhs.romanization.compare(rhs.romanization, locale: englishLocale)
                guard romanizationCompare == .orderedSame else { return romanizationCompare == .orderedAscending }
                let words: [String] = [lhs.word, rhs.word]
                let sortedWords: [String] = words.sortedWithUnicodeCodePoint()
                return sortedWords[0] == words[0]
        }
}

struct JyutpingGenerator {

        static func generate() {
                let dictPath: String = "output/dict.tsv"
                let essayPath: String = "output/essay.txt"
                let originalLines: [String] = readFileLines()
                let converted = originalLines.map({ convertLine($0) })
                let normalEntries: [JyutpingEntry] = converted.flatMap({ $0 }).uniqued()
                let chemicalFormulaEntries: [JyutpingEntry] = processChemicalFormula()
                let entries: [JyutpingEntry] = normalEntries + chemicalFormulaEntries
                let dictContent: String = entries.sorted().map(\.description).joined(separator: String.newLine) + String.newLine
                let essayContent: String = entries.map(\.word).uniqued().sortedWithUnicodeCodePoint().joined(separator: String.newLine) + String.newLine
                if FileManager.default.fileExists(atPath: dictPath) {
                        try? FileManager.default.removeItem(atPath: dictPath)
                }
                if FileManager.default.fileExists(atPath: essayPath) {
                        try? FileManager.default.removeItem(atPath: essayPath)
                }
                do {
                        try dictContent.write(toFile: dictPath, atomically: true, encoding: .utf8)
                        try essayContent.write(toFile: essayPath, atomically: true, encoding: .utf8)
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

        private static func processChemicalFormula() -> [JyutpingEntry] {
                let path: String = "chemical-formula.txt"
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
                let entryBlocks = sourceLines.map({ line -> [JyutpingEntry] in
                        let parts = line.split(separator: "\t")
                        guard parts.count == 2 else {
                                fatalError("Bad format: \(line)")
                        }
                        let namePart = parts[1]
                        let nameBlocks = namePart.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                        let entries = nameBlocks.map({ block -> [JyutpingEntry] in
                                let nameComponents = block.split(separator: "(")
                                guard nameComponents.count == 2 else {
                                        fatalError("Bad format: \(line)")
                                }
                                let word = nameComponents[0].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters)
                                let romanizations = nameComponents[1].replacingOccurrences(of: ")", with: "").split(separator: ";").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
                                return romanizations.map({ JyutpingEntry(word: word, romanization: $0) })
                        })
                        return entries.flatMap({ $0 })
                })
                return entryBlocks.flatMap({ $0 })
        }
}
