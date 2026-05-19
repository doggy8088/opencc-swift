import OpenCCSwift

let converter = try OpenCC.converter(from: "hk", to: "cn")
let xml = """
<html lang="zh-HK">
  <body>
    <h1>漢語轉換示例</h1>
    <p lang="zh-HK">伺服器與網絡服務已啟動。</p>
    <p lang="en">This paragraph should stay unchanged.</p>
  </body>
</html>
"""
let html = try HtmlConverter(converter: converter, xml: xml, fromLangTag: "zh-HK", toLangTag: "zh-CN")

html.convert()
print("轉換後：")
print(html.xmlString())

try html.restore()
print()
print("還原後：")
print(html.xmlString())
