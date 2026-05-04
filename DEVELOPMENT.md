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
