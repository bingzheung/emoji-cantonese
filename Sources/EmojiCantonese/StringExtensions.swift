import Foundation

extension String {

        /// Convert traditional characters to simplified
        /// - Returns: Simplified characters
        func simplified() -> String {
                return applyingTransform(Self.s2t_transform, reverse: true) ?? self
        }
        private static let s2t_transform = StringTransform("Simplified-Traditional")
}

extension String {

        /// A subsequence that only contains tones (1-6)
        var tones: String {
                return self.filter(\.isTone)
        }

        /// Remove all tones (1-6)
        /// - Returns: A subsequence that leaves off the tones.
        func removedTones() -> String {
                return self.filter({ !$0.isTone })
        }

        /// Remove all spaces and tones
        /// - Returns: A subsequence that leaves off the spaces and tones.
        func removedSpacesTones() -> String {
                return self.filter({ !$0.isSpaceOrTone })
        }
}

extension String {

        var symbolCodePointText: String {
                return self.map(\.emojiCodePointText).joined(separator: ".")
        }
}
