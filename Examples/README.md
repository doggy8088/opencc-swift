# OpenCCSwift 範例

這個資料夾收錄 SwiftPM 可執行範例。每個範例都有獨立資料夾與 README，說明用途與細節。

## 範例列表

| 範例 | 用途 |
| --- | --- |
| [BasicExample](BasicExample/) | 基本簡體轉臺灣繁體。 |
| [NoPhraseConversion](NoPhraseConversion/) | 只做字形轉換，不套用地區詞彙。 |
| [LocaleDifferences](LocaleDifferences/) | 比較不同簡繁詞庫輸出。 |
| [CustomExample](CustomExample/) | 使用自訂詞典。 |
| [HtmlExample](HtmlExample/) | 轉換 XML/HTML 片段並還原。 |

## 執行方式

在 `opencc-swift/` 目錄下執行：

```bash
swift run BasicExample
swift run NoPhraseConversion
swift run LocaleDifferences
swift run CustomExample
swift run HtmlExample
```
