import OpenCCSwift

let raw = OpenCC.customConverter("香蕉 banana|蘋果 apple|梨 pear")
print(raw.convert("香蕉 蘋果 梨"))

let punctuation = OpenCC.customConverter([
    DictEntry("“", "「"),
    DictEntry("”", "」"),
])
print(punctuation.convert("悟空道:“师父又来了。”"))
