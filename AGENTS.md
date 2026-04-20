# AGENTS

## Project overview

This repository is a Swift executable package that generates Cantonese emoji dictionaries from root-level text data files.

- Package: `EmojiCantonese`
- Entry point: `Sources/EmojiCantonese/EmojiCantonese.swift`
- Primary command: `swift run`
- Test command: `swift test`

Always run commands from the repository root. The generator reads input files from `FileManager.default.currentDirectoryPath`, so changing directories will break file discovery.

## Repository layout

- `Sources/EmojiCantonese/`
  - `Checker.swift`: validates the main emoji and symbol source files before generation.
  - `OpenCCEmoji.swift`: builds `output/emoji.txt`.
  - `JyutpingGenerator.swift`: builds `output/dict.tsv` and `output/essay.txt`.
  - `JyutpingChecker.swift`: validates Jyutping syllables and sequences.
- `Tests/EmojiCantoneseTests/`: minimal XCTest coverage.
- Root `emoji-*.txt`, `symbol-*.txt`, and related `.txt` files: source data.
- `output/`: generated artifacts.

## Source-of-truth files

These root files are the editable inputs:

- `emoji-*.txt`
- `symbol-*.txt`
- `extra-emoji.txt`
- `chemical-formula.txt`
- `lettered-emoji.txt`
- `light-skin-tone.txt`

Do not hand-edit files in `output/`. Regenerate them with `swift run`.

## Generation flow

`swift run` executes three steps in order:

1. `Checker.check()`
2. `OpenCCEmoji.generate()`
3. `JyutpingGenerator.generate()`

That means:

- malformed data files fail the run before outputs are regenerated;
- `output/emoji.txt` depends on `emoji-*.txt`, `extra-emoji.txt`, `lettered-emoji.txt`, and `light-skin-tone.txt`;
- `output/dict.tsv` and `output/essay.txt` depend on `emoji-*.txt`, `symbol-*.txt`, `extra-emoji.txt`, and `chemical-formula.txt`.

File discovery is name-based. The code looks for files by prefix such as `emoji-` and `symbol-`, plus exact names like `extra-emoji.txt`. Do not rename or move these files unless you also update the scanners in code.

## Data format rules

### `emoji-*.txt`, `symbol-*.txt`, `extra-emoji.txt`

These files use tab-separated rows:

`CODEPOINT<TAB>{ emoji }<TAB>Name(jyutping), OtherName(jyutping1; jyutping2)`

Rules enforced by the checker:

- exactly 3 tab-separated fields per non-comment row;
- emoji field must be wrapped in `{ ... }`;
- names are comma-separated;
- each name block must include Cantonese text plus Jyutping in parentheses;
- alternate Jyutping readings for the same written form use `;`;
- the Cantonese text in checked files must stay non-ASCII and non-punctuation;
- each Chinese character count must match the Jyutping syllable count.

Lines beginning with `#` are ignored by the checker.

### `chemical-formula.txt`

This file uses:

`{ formula }<TAB>Name(jyutping), OtherName(jyutping1; jyutping2)`

It is consumed by `JyutpingGenerator` but not by `Checker`.

### `lettered-emoji.txt`

This file also uses 3 tab-separated fields, but its names are plain strings such as Latin-letter labels. It contributes only to `output/emoji.txt`.

### `light-skin-tone.txt`

This file maps a default emoji to its light-skin-tone variant and is used only when generating `output/emoji.txt`.

## Editing guidance

- Preserve the existing strict validation style. This project prefers rejecting malformed input over silently accepting bad data.
- Keep changes surgical. Most feature work in this repo is either:
  - editing root data files, then regenerating outputs; or
  - updating generator logic, then regenerating outputs.
- If you touch any generator input or output logic, run `swift run`.
- Run `swift test` after code or documentation changes that affect workflow expectations.

## Style

Follow `.editorconfig`
