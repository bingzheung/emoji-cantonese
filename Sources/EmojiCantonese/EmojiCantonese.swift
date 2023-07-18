import Foundation

@main
public struct EmojiCantonese {

        public static func main() {
                OpenCCEmoji.generate()
                JyutpingGenerator.generate()
                DatabaseGenerator.generate()
        }
}
