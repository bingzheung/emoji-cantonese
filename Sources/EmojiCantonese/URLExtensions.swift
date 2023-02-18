import Foundation

extension URL {

        func readLines() -> [String] {
                guard let content: String = try? String(contentsOf: self) else {
                        fatalError("Failed to read content of URL: \(self)")
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
        }
}
