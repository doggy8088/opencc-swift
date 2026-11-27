# Development Guide

## Architecture

This package ports the local C# OpenCC implementation directly:

1. `DictData` constants are generated from `OpenCC/src/OpenCC/Internal/DictData.cs`.
2. `Locale` maps mirror `LocaleData.cs`.
3. `Presets.Full`, `Presets.Cn2t`, and `Presets.T2cn` mirror the C# preset maps.
4. `Converter` owns one `Trie` per dictionary group and applies them sequentially.
5. `Trie` walks `UnicodeScalar` values and uses longest-match wins.
6. `HtmlConverter` uses FoundationXML's `XMLDocument` for XML-compatible HTML and keeps the original XML data for `restore()`.

## Dictionary format

Raw dictionaries follow the original compact format:

```text
來源 目標|來源2 目標2
```

Malformed entries with fewer than two space-separated fields are ignored, matching the C# implementation.

## Validation checklist

Run this before publishing changes:

```bash
swift test
swift run BasicExample
swift run CustomExample
swift run HtmlExample
```

## Regenerating embedded dictionaries

If the upstream C# dictionary changes, regenerate `Sources/OpenCCSwift/DictData.swift` from `OpenCC/src/OpenCC/Internal/DictData.cs` and rerun the full test suite. Keep the generated file as a simple constant table; conversion logic belongs in `Sources/OpenCCSwift/OpenCCSwift.swift`.

## Releasing

SwiftPM resolves versions from git tags, so a release is a `v<version>` tag plus a GitHub Release. The version lives in the `VERSION` file.

`.github/workflows/ci.yml` runs `swift test` on every push and pull request. On a push to `main`, after the tests pass, it reads `VERSION`:

- No `v<version>` tag yet: create the tag and a GitHub Release whose notes list the commits since the previous tag.
- The tag already exists: skip.

To release, bump `VERSION` (for example `0.1.2`), commit, and push to `main`.


## 本機與 CI 驗證分工

- 啟用本機 pre-commit hook（每個 clone 設定一次）：`git config core.hooksPath .githooks`
- 分工原則：本機負責 format 與快速回歸；CI 負責完整測試矩陣與「乾淨環境」驗證。hook 只放快檢查，慢測試一律交給 CI，避免被 `--no-verify` 繞過。
- 本機 hook：只做 `git diff --cached --check`。`swift test` 需數分鐘，明載不放進 hook。
- CI：`ci.yml`（macOS）跑完整 `swift test`，以 CI 為準。
