import OpenCCSwift

let converter = try OpenCC.converter(from: "hk", to: "cn")
let xml = "<html lang='zh-HK'><body><p lang='zh-HK'>漢語</p></body></html>"
let html = try HtmlConverter(converter: converter, xml: xml, fromLangTag: "zh-HK", toLangTag: "zh-CN")

html.convert()
print(html.xmlString())
try html.restore()
