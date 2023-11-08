struct JyutpingChecker {

        static func isValidJyutpingSequence<T: StringProtocol>(text: T) -> Bool {
                guard !(text.hasPrefix(" ") || text.hasSuffix(" ")) else { return false }
                guard !(text.contains("  ")) else { return false }
                let blocks = text.split(separator: " ")
                var isValid: Bool = true
                for block in blocks {
                        isValid = isValidJyutping(text: block)
                        if !(isValid) {
                                break
                        }
                }
                return isValid
        }

        static func isValidJyutping<T: StringProtocol>(text: T) -> Bool {
                guard let tone = text.last else { return false }
                guard tones.contains(tone) else { return false }
                let withoutTone = text.dropLast()
                let m_or_ng: Bool = withoutTone == "m" || withoutTone == "ng"
                guard !m_or_ng else { return true }
                let isPluralInitial: Bool = text.hasPrefix("ng") || text.hasPrefix("gw") || text.hasPrefix("kw")
                if isPluralInitial {
                        let final = withoutTone.dropFirst(2)
                        return finals.contains(String(final))
                } else {
                        let lingShingMou: Bool = finals.contains(String(withoutTone))
                        guard !lingShingMou else { return true }
                        let final = withoutTone.dropFirst()
                        return finals.contains(String(final))
                }
        }

        /// Check tone-free Jyutping syllable
        /// - Parameter text: Jyutping syllable without tone
        /// - Returns: Is valid syllable
        static func isValidSyllable<T: StringProtocol>(text: T) -> Bool {
                let m_or_ng: Bool = text == "m" || text == "ng"
                guard !m_or_ng else { return true }
                let isPluralInitial: Bool = text.hasPrefix("ng") || text.hasPrefix("gw") || text.hasPrefix("kw")
                if isPluralInitial {
                        let final = text.dropFirst(2)
                        return finals.contains(String(final))
                } else {
                        let lingShingMou: Bool = finals.contains(String(text))
                        guard !lingShingMou else { return true }
                        let final = text.dropFirst()
                        return finals.contains(String(final))
                }
        }

        private static let initials: Set<String> = [
                "b",
                "p",
                "m",
                "f",
                "d",
                "t",
                "n",
                "l",
                "g",
                "k",
                "ng",
                "h",
                "gw",
                "kw",
                "w",
                "z",
                "c",
                "s",
                "j",
        ]
        private static let singularInitials: Set<Character> = [
                "b",
                "p",
                "m",
                "f",
                "d",
                "t",
                "n",
                "l",
                "g",
                "k",
                "h",
                "w",
                "z",
                "c",
                "s",
                "j",
        ]
        private static let finals: Set<String> = [
                "aa",
                "aai",
                "aau",
                "aam",
                "aan",
                "aang",
                "aap",
                "aat",
                "aak",

                "a",
                "ai",
                "au",
                "am",
                "an",
                "ang",
                "ap",
                "at",
                "ak",

                "e",
                "ei",
                "eu",
                "em",
                "en",
                "eng",
                "ep",
                "et",
                "ek",

                "i",
                "iu",
                "im",
                "in",
                "ing",
                "ip",
                "it",
                "ik",

                "o",
                "oi",
                "ou",
                "on",
                "ong",
                "ot",
                "ok",

                "u",
                "ui",
                "um",
                "un",
                "ung",
                "up",
                "ut",
                "uk",

                "oe",
                "oeng",
                "oet",
                "oek",

                "eoi",
                "eon",
                "eot",

                "yu",
                "yun",
                "yut"
        ]
        private static let tones: Set<Character> = ["1", "2", "3", "4", "5", "6"]
}
