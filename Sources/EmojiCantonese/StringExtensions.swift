import Foundation

extension String {

        /// Convert traditional characters to simplified
        /// - Returns: Simplified characters
        func simplified() -> String {
                return applyingTransform(Self.s2t_transform, reverse: true) ?? self
        }
        private static let s2t_transform = StringTransform("Simplified-Traditional")
}
