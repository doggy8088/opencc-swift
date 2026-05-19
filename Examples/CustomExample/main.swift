import OpenCCSwift

let raw = OpenCC.customConverter("香蕉 banana|蘋果 apple|梨 pear|用户界面 使用者介面|用户 使用者")
print(raw.convert("香蕉 蘋果 梨 和用户界面"))

let punctuation = OpenCC.customConverter([
    DictEntry("“", "「"),
    DictEntry("”", "」"),
])
print(punctuation.convert("悟空道:“师父又来了。”"))
