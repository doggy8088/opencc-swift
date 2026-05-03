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

@Test func builtInConverterConvertsHighConfidenceTaiwanTechTermsToTw2() throws {
    let converter = try OpenCC.converter(from: "cn", to: "tw2")
    let cases = [
        ("电子邮件", "電子郵件"),
        ("数据库", "資料庫"),
        ("网络服务", "網路服務"),
        ("应用程序网关", "應用程式閘道"),
        ("镜像文件", "映像檔"),
        ("保存更改", "儲存變更"),
    ]

    for (source, expected) in cases {
        #expect(converter.convert(source) == expected)
    }
}

@Test func builtInConverterHandlesCnToTw2ResearchEdgeCases() throws {
    let converter = try OpenCC.converter(from: "cn", to: "tw2")
    let cases = [
        ("数据结构数据库", "資料結構資料庫"),
        ("响应式编程响应头", "回應式程式設計回應標頭"),
        ("命令行工具", "命令列工具"),
        ("Web 平台库", "Web 平台函式庫"),
        ("for 循环和while 循环", "for 迴圈和while 迴圈"),
        ("控制台打印日志", "輸出到 Console記錄"),
        ("元数据 API", "Metadata API"),
        ("类（ Class ）加载器", "類別（ Class ）載入器"),
        ("“数据库”, “网络请求”", "“資料庫”, “網路請求”"),
        ("项目设置：默认值", "專案設定：預設值"),
        ("「类」", "「類別」"),
        ("类。", "類別。"),
        ("（视频）", "（影片）"),
        ("千钧一发", "千鈞一髮"),
        ("一触即发", "一觸即發"),
        ("百发百中", "百發百中"),
        ("爆发发布", "爆發發表"),
        ("台湾台球桌", "台灣撞球桌"),
        ("折叠粘土", "折疊黏土"),
    ]

    for (source, expected) in cases {
        #expect(converter.convert(source) == expected)
    }
}

@Test func builtInConverterHandlesCnToTw2SentenceEdgeCases() throws {
    let converter = try OpenCC.converter(from: "cn", to: "tw2")
    let cases = [
        ("默认用户界面支持数据库和网络请求。", "預設使用者介面支援資料庫和網路請求。"),
        ("命令行工具加载配置文件。", "命令列工具載入組態檔。"),
        ("创建软件项目目录和项目设置。", "建立軟體專案目錄和專案設定。"),
        ("调试器显示调用堆栈和断点。", "偵錯工具顯示呼叫堆疊和中斷點。"),
        ("响应式编程教程包含缓存策略。", "回應式程式設計課程包含快取策略。"),
        ("我们的程序使用数据库和线程。", "我們的應用程式使用資料庫和執行緒。"),
        ("请打开用户界面并刷新屏幕。", "請打開使用者介面並重新整理螢幕。"),
        ("API 返回默认值和错误消息。", "API 返回預設值和錯誤訊息。"),
        ("在 while 循环中调用函数。", "在 while 迴圈中呼叫函式。"),
        ("for 循环处理数组和字符串。", "for 迴圈處理陣列和字串。"),
        ("配置文件位于项目目录。", "組態檔位於專案目錄。"),
        ("命令行工具输出调试信息。", "命令列工具輸出偵錯資訊。"),
        ("代码审查发现内存泄漏。", "程式碼審查發現記憶體洩漏。"),
        ("进程间通信和多线程", "行程間通訊和多執行緒"),
    ]

    for (source, expected) in cases {
        #expect(converter.convert(source) == expected)
    }
}

@Test func builtInConverterHandlesCnToTw2MixedMediaUiAndUnicodeCases() throws {
    let converter = try OpenCC.converter(from: "cn", to: "tw2")
    let cases = [
        ("接口和抽象类", "介面和抽象類別"),
        ("控制台打印", "輸出到 Console"),
        ("文档注释", "文件註解"),
        ("监控摄像头", "監視攝影機"),
        ("赛博朋克", "賽博龐克"),
        ("黑客帝国", "駭客任務"),
        ("星球大战", "星際大戰"),
        ("指环王", "魔戒"),
        ("泰坦尼克号", "鐵達尼號"),
        ("星际穿越", "星際效應"),
        ("钢铁侠", "鋼鐵人"),
        ("单反相机", "單眼相機"),
        ("鼠标事件", "滑鼠事件"),
        ("菜单链接账户账号", "選單連結帳戶帳號"),
        ("🚀发布数据库 v2.0", "🚀發表資料庫 v2.0"),
    ]

    for (source, expected) in cases {
        #expect(converter.convert(source) == expected)
    }
}

@Test func builtInConverterDocumentsCurrentPublishReleaseBehaviorToTw2() throws {
    let converter = try OpenCC.converter(from: "cn", to: "tw2")
    let cases = [
        ("软件发布", "軟體發表"),
        ("发布响应式编程教程", "發表回應式程式設計課程"),
        ("发布数据库迁移脚本", "發表資料庫遷移指令碼"),
        ("发布公告", "發表公告"),
        ("发布新版本", "發表新版本"),
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
