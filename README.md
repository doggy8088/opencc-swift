# OpenCCSwift

`OpenCCSwift` 是依照 [OpenCC for C#](https://github.com/doggy8088/opencc) 實作移植的 SwiftPM OpenCC 函式庫。核心行為保留原實作的內嵌字典、locale preset、Trie 最長匹配與多階段轉換流程。

## 功能

- 內建 `cn`、`hk`、`tw`、`tw2`、`twp`、`jp` locale。
- 支援 `Full`、`Cn2t`、`T2cn` preset。
- 支援自訂字典與多個字典群組串接。
- 以 `UnicodeScalar` 實作 Trie，符合 C# Rune/code point 轉換語意。
- 支援 XML-compatible HTML 轉換與還原。
- MIT 授權，與原 C# OpenCC 專案相同。

## 新手上路

### 開發環境需求

- Swift 6.0+
- Swift Package Manager
- Xcode Command Line Tools 或 Xcode
- Git

檢查環境：

```bash
swift --version
git --version
```

### 加入專案

在你的 `Package.swift` 加入：

```swift
.package(url: "https://github.com/doggy8088/opencc-swift.git", branch: "main")
```

並在 target dependency 加入：

```swift
.product(name: "OpenCCSwift", package: "opencc-swift")
```

### 第一個程式

```swift
import OpenCCSwift

let converter = try OpenCC.converter(from: "cn", to: "tw2")
print(converter.convert("汉语")) // 漢語
```

## Locale 與 preset

預設 `OpenCC.converter(from:to:)` 使用 full preset：

| from/to | 說明 |
| --- | --- |
| `cn` | 中國大陸簡體 |
| `hk` | 香港繁體異體字 |
| `tw` | 台灣繁體異體字 |
| `tw2` | 台灣繁體常用詞 |
| `twp` | 台灣繁體含 IT、姓名與其他詞彙 |
| `jp` | 日本新字體/異體字 |
| `t` | passthrough，不載入該階段字典 |

方向限定 preset：

```swift
let cnToTw = try Presets.Cn2t.converter(from: "cn", to: "tw2")
let twToCn = try Presets.T2cn.converter(from: "tw", to: "cn")
```

## 自訂字典

字串格式與 C# 實作相同：每筆 `來源 目標`，筆與筆之間以 `|` 分隔。

```swift
let converter = OpenCC.customConverter("香蕉 banana|蘋果 apple|梨 pear")
print(converter.convert("香蕉 蘋果 梨")) // banana apple pear
```

也可以使用 `DictEntry`：

```swift
let converter = OpenCC.customConverter([
    DictEntry("“", "「"),
    DictEntry("”", "」"),
])
```

## 進階組合

`OpenCC.converterFactory(_:)` 會依序套用每個 `DictGroup`，等同 C# 版本先處理 `from` 群組，再處理 `to` 群組。

```swift
let first = DictGroup.fromEntries([DictEntry("a", "b")])
let second = DictGroup.fromEntries([DictEntry("b", "c")])
let converter = OpenCC.converterFactory([first, second])
print(converter.convert("a")) // c
```

## XML-compatible HTML 轉換

與 C# 版本一樣，這裡處理的是可被 XML parser 解析的 HTML/XML。會轉換 lang 範圍內的文字節點、`meta[name=description|keywords]` 的 `content`、`img alt`、`input[type=button] value`，略過 `script`、`style` 與 `ignore-opencc` class。

```swift
let converter = try OpenCC.converter(from: "hk", to: "cn")
let xml = "<html lang='zh-HK'><body><p lang='zh-HK'>漢語</p></body></html>"
let html = try HtmlConverter(converter: converter, xml: xml, fromLangTag: "zh-HK", toLangTag: "zh-CN")
html.convert()
print(html.xmlString())
try html.restore()
```

## 開發

```bash
swift test
swift run BasicExample
swift run CustomExample
swift run HtmlExample
```

更多移植細節請見 `DEVELOPMENT.md`。

## License

MIT
