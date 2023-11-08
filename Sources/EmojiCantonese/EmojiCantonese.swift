import Foundation

@main
public struct EmojiCantonese {

        public static func main() {
                Checker.check()
                OpenCCEmoji.generate()
                JyutpingGenerator.generate()
                DatabaseGenerator.generate()
        }
}
