import Testing
@testable import OpenCCSwift

@Test func trieUsesLongestMatch() {
    let trie = Trie()
    trie.addWord(source: "ab", target: "X")
    trie.addWord(source: "a", target: "Y")

    #expect(trie.convert("abca") == "XcY")
}

@Test func trieLoadsPipeSeparatedDictionaryAndSkipsMalformedLines() {
    let trie = Trie()
    trie.loadDict("a b|invalid|c d|Web 平台庫\tWeb 平台函式庫")

    #expect(trie.convert("a") == "b")
    #expect(trie.convert("c") == "d")
    #expect(trie.convert("Web 平台庫") == "Web 平台函式庫")
    #expect(trie.convert("x") == "x")
}

@Test func converterFactoryConvertsSequentially() {
    let group1 = DictGroup.fromEntries([DictEntry("a", "b")])
    let group2 = DictGroup.fromEntries([DictEntry("b", "c")])

    let converter = OpenCC.converterFactory([group1, group2])

    #expect(converter.convert("a") == "c")
}

@Test func builtInConverterConvertsCnToTw2() throws {
    let converter = try OpenCC.converter(from: "cn", to: "tw2")

    #expect(converter.convert("汉语") == "漢語")
}

@Test func builtInConverterConvertsPreferredTaiwanTermsToTw2() throws {
    let converter = try OpenCC.converter(from: "cn", to: "tw2")
    let cases = [
        ("视频", "影片"),
        ("音频", "音訊"),
        ("软件", "軟體"),
        ("硬件", "硬體"),
        ("程序", "程式"),
        ("进程", "行程"),
        ("进程间通信", "行程間通訊"),
        ("线程", "執行緒"),
        ("数据", "資料"),
        ("数据库", "資料庫"),
        ("网络", "網路"),
        ("信息", "資訊"),
        ("质量", "品質"),
        ("用户", "使用者"),
        ("默认", "預設"),
        ("创建", "建立"),
        ("实现", "實作"),
        ("运行", "執行"),
        ("发布", "發表"),
        ("屏幕", "螢幕"),
        ("界面", "介面"),
        ("文档", "文件"),
        ("操作系统", "作業系統"),
        ("剑指", "針對"),
        ("痛点", "要害"),
        ("硬伤", "罩門"),
    ]

    for (source, expected) in cases {
        #expect(converter.convert(source) == expected)
    }
}

@Test func builtInConverterConvertsTwToCn() throws {
    let converter = try OpenCC.converter(from: "tw", to: "cn")

    #expect(converter.convert("漢語") == "汉语")
}

@Test func customConvertersConvertEntriesAndRawDictionary() {
    let raw = OpenCC.customConverter("香蕉 banana|蘋果 apple|梨 pear")
    let entries = OpenCC.customConverter([
        DictEntry("banana", "香蕉"),
        DictEntry("apple", "蘋果"),
    ])

    #expect(raw.convert("香蕉 蘋果 梨") == "banana apple pear")
    #expect(entries.convert("banana apple") == "香蕉 蘋果")
}

@Test func converterReportsMissingAndUnknownLocales() {
    #expect(throws: OpenCCError.missingLocale(kind: "from")) {
        try OpenCC.converter(from: "", to: "cn")
    }

    #expect(throws: OpenCCError.unknownLocale(kind: "from", locale: "missing")) {
        try OpenCC.converter(from: "missing", to: "cn")
    }
}

@Test func presetsRestrictSupportedDirections() throws {
    _ = try Presets.Cn2t.converter(from: "cn", to: "tw2")
    #expect(throws: OpenCCError.unknownLocale(kind: "from", locale: "tw")) {
        try Presets.Cn2t.converter(from: "tw", to: "cn")
    }

    _ = try Presets.T2cn.converter(from: "tw2", to: "cn")
    #expect(throws: OpenCCError.unknownLocale(kind: "from", locale: "cn")) {
        try Presets.T2cn.converter(from: "cn", to: "tw")
    }
}

@Test func htmlConverterConvertsXmlCompatibleHtmlAndRestores() throws {
    let converter = OpenCC.customConverter("hello HELLO|keywords KEYWORDS")
    let xml = #"<html lang="zh"><head><meta name="description" content="hello"/><meta name="keywords" content="keywords"/></head><body><p>hello</p><img alt="hello"/><input type="button" value="hello"/><input type="text" value="hello"/><div class="ignore-opencc">hello</div><span lang="en">hello</span><script>hello</script><style>hello</style></body></html>"#
    let html = try HtmlConverter(converter: converter, xml: xml, fromLangTag: "zh", toLangTag: "zh-Hant")

    html.convert()
    let converted = html.xmlString()

    #expect(converted.contains(#"lang="zh-Hant""#))
    #expect(converted.contains(">HELLO</p>"))
    #expect(converted.contains(#"content="HELLO""#))
    #expect(converted.contains(#"content="KEYWORDS""#))
    #expect(converted.contains(#"alt="HELLO""#))
    #expect(converted.contains(#"value="HELLO""#))
    #expect(converted.contains(#"<span lang="en">hello</span>"#))
    #expect(converted.contains(#"<script>hello</script>"#))
    #expect(converted.contains(#"<style>hello</style>"#))

    try html.restore()
    let restored = html.xmlString()
    #expect(restored.contains(#"lang="zh""#))
    #expect(restored.contains(">hello</p>"))
}
