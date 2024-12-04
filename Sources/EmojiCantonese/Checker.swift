import Foundation

enum CheckerError: Error {
        case fileNotExists
        case canNotReadFile
        case fileIsEmpty
        case badLineFormat
}

struct Checker {

        static func check() {
                let currentPath: String = FileManager.default.currentDirectoryPath
                guard let contents: [String] = try? FileManager.default.contentsOfDirectory(atPath: currentPath) else {
                        fatalError("Failed to fetch contents of path: \(currentPath)")
                }
                let paths: [String] = contents.filter({ $0.hasPrefix("emoji-") || $0.hasPrefix("symbol-") || $0.hasPrefix("extra-emoji") }).sorted()
                for path in paths {
                        try! check(filePath: path)
                }
        }

        private static func check(filePath: String) throws {
                guard FileManager.default.fileExists(atPath: filePath) else {
                        print("File Path: \(filePath)")
                        throw CheckerError.fileNotExists
                }
                guard let sourceContent: String = try? String(contentsOfFile: filePath, encoding: .utf8) else {
                        print("File Path: \(filePath)")
                        throw CheckerError.canNotReadFile
                }
                let sourceLines: [String] = sourceContent
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .components(separatedBy: .newlines)
                        .filter({ !($0.isEmpty || $0.hasPrefix("#")) })
                guard !(sourceLines.isEmpty) else {
                        print("File Path: \(filePath)")
                        throw CheckerError.fileIsEmpty
                }
                for line in sourceLines {
                        let parts = line.split(separator: "\t", omittingEmptySubsequences: false)
                        guard parts.count == 3 else {
                                print("LineText: \(line)")
                                throw CheckerError.badLineFormat
                        }
                        let emojiPart = parts[1]
                        let names = parts[2]
                        try checkEmojiPart(text: line, emojiPart: emojiPart)
                        try checkNames(text: line, names: names)
                }
        }
        private static func checkEmojiPart<T: StringProtocol>(text: String, emojiPart: T) throws {
                guard emojiPart.hasPrefix("{") && emojiPart.hasSuffix("}") else {
                        print("LineText: \(text)")
                        throw CheckerError.badLineFormat
                }
        }
        private static func checkNames<T: StringProtocol>(text: String, names: T) throws {
                guard !(names.contains("  ")) else {
                        print("LineText: \(text)")
                        throw CheckerError.badLineFormat
                }
                let blocks = names.split(separator: ",", omittingEmptySubsequences: false).map({ $0.trimmingCharacters(in: .whitespaces) })
                for block in blocks {
                        let parts = block.split(separator: "(")
                        guard parts.count == 2 else {
                                print("LineText: \(text)")
                                throw CheckerError.badLineFormat
                        }
                        let cantonese = parts[0]
                        let romanizations = parts[1].dropLast().split(separator: ";").map({ $0.trimmingCharacters(in: .whitespaces) })
                        let isFineWord: Bool = cantonese.filter({ $0.isPunctuation || $0.isWhitespace || $0.isASCII }).isEmpty
                        guard isFineWord else {
                                print("LineText: \(text)")
                                throw CheckerError.badLineFormat
                        }
                        let isValid = romanizations.map({ JyutpingChecker.isValidJyutpingSequence(text: $0) }).reduce(true, { $0 && $1 })
                        guard isValid else {
                                print("LineText: \(text)")
                                throw CheckerError.badLineFormat
                        }
                        for romanization in romanizations {
                                let syllables = romanization.split(separator: " ")
                                guard cantonese.count == syllables.count else {
                                        print("LineText: \(text)")
                                        throw CheckerError.badLineFormat
                                }
                        }
                }
        }
}
