import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public enum OpenCCError: Error, Equatable, LocalizedError {
    case missingLocale(kind: String)
    case unknownLocale(kind: String, locale: String)
    case xml(String)

    public var errorDescription: String? {
        switch self {
        case let .missingLocale(kind):
            return "Please provide the `\(kind)` option"
        case let .unknownLocale(kind, locale):
            return "Unknown locale `\(locale)` for `\(kind)` option"
        case let .xml(message):
            return "XML error: \(message)"
        }
    }
}

public struct ConverterOptions: Equatable, Sendable {
    public var from: String
    public var to: String

    public init(from: String = "", to: String = "") {
        self.from = from
        self.to = to
    }
}

public struct DictEntry: Equatable, Sendable {
    public var source: String
    public var target: String

    public init(_ source: String, _ target: String) {
        self.source = source
        self.target = target
    }
}

public enum Dict: Equatable, Sendable {
    case raw(String)
    case entries([DictEntry])

    func load(into trie: Trie) {
        switch self {
        case let .raw(data):
            trie.loadDict(data)
        case let .entries(entries):
            trie.loadEntries(entries)
        }
    }
}

public struct DictGroup: Equatable, Sendable {
    private var dicts: [Dict]

    public init(_ dicts: [Dict]) {
        self.dicts = dicts
    }

    public static func fromStrings(_ dicts: String...) -> DictGroup {
        DictGroup(dicts.map(Dict.raw))
    }

    public static func fromStrings(_ dicts: [String]) -> DictGroup {
        DictGroup(dicts.map(Dict.raw))
    }

    public static func fromEntries(_ dicts: [DictEntry]...) -> DictGroup {
        DictGroup(dicts.map(Dict.entries))
    }

    public func concat(_ dict: Dict) -> DictGroup {
        DictGroup(dicts + [dict])
    }

    public func concat(_ more: [Dict]) -> DictGroup {
        DictGroup(dicts + more)
    }

    public var count: Int {
        dicts.count
    }

    func load(into trie: Trie) {
        for dict in dicts {
            dict.load(into: trie)
        }
    }
}

final class TrieNode {
    var children: [UnicodeScalar: TrieNode] = [:]
    var value: String?
}

public final class Trie {
    private let root = TrieNode()

    public init() {}

    public func addWord(source: String, target: String) {
        var node = root
        for scalar in source.unicodeScalars {
            if node.children[scalar] == nil {
                node.children[scalar] = TrieNode()
            }
            node = node.children[scalar]!
        }
        node.value = target
    }

    public func loadDict(_ dict: String) {
        for line in dict.split(whereSeparator: { $0 == "|" || $0 == "\n" }) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                continue
            }

            let separator = trimmed.firstIndex(of: "\t") ?? trimmed.firstIndex(of: " ")
            guard let separator else {
                continue
            }

            addWord(
                source: String(trimmed[..<separator]),
                target: String(trimmed[trimmed.index(after: separator)...])
            )
        }
    }

    public func loadEntries(_ dict: [DictEntry]) {
        for entry in dict {
            addWord(source: entry.source, target: entry.target)
        }
    }

    public func loadDictGroup(_ group: DictGroup) {
        group.load(into: self)
    }

    public func convert(_ input: String) -> String {
        if input.isEmpty {
            return ""
        }

        let scalars = Array(input.unicodeScalars)
        var result = ""
        var pending: [UnicodeScalar] = []
        var index = 0

        while index < scalars.count {
            var node = root
            var matchedEnd: Int?
            var matchedValue: String?
            var cursor = index

            while cursor < scalars.count {
                guard let next = node.children[scalars[cursor]] else {
                    break
                }

                cursor += 1
                node = next

                if let value = node.value {
                    matchedEnd = cursor
                    matchedValue = value
                }
            }

            if let end = matchedEnd {
                result.unicodeScalars.append(contentsOf: pending)
                pending.removeAll(keepingCapacity: true)
                result += matchedValue ?? ""
                index = end
            } else {
                pending.append(scalars[index])
                index += 1
            }
        }

        result.unicodeScalars.append(contentsOf: pending)
        return result
    }
}

public struct LocalePreset {
    public let from: [String: DictGroup]
    public let to: [String: DictGroup]

    public init(from: [String: DictGroup], to: [String: DictGroup]) {
        self.from = from
        self.to = to
    }
}

public struct Converter {
    private let tries: [Trie]

    public init(dictGroups: [DictGroup]) {
        tries = dictGroups.map { group in
            let trie = Trie()
            trie.loadDictGroup(group)
            return trie
        }
    }

    public func convert(_ input: String) -> String {
        tries.reduce(input) { current, trie in
            trie.convert(current)
        }
    }
}

public enum Locale {
    public enum From {
        private static let tw2QualityPhrasesRev = """
            檔名	文件名
            檔案系統	文件系統
            檔案描述子	文件描述符
            函式呼叫	函數調用
            算繪管線	渲染管線
            記憶體配置	內存分配
            網路堆疊	網絡棧
            網路介面卡	網絡適配器
            """

        public static var cn: DictGroup {
            DictGroup.fromStrings(DictData.STCharacters, DictData.STPhrases)
        }

        public static var hk: DictGroup {
            DictGroup.fromStrings(DictData.HKVariantsRev, DictData.HKVariantsRevPhrases)
        }

        public static var tw: DictGroup {
            DictGroup.fromStrings(DictData.TWVariantsRev, DictData.TWVariantsRevPhrases)
        }

        public static var tw2: DictGroup {
            DictGroup.fromStrings(DictData.TWVariantsRev, DictData.TWPhrasesCustomRev, tw2QualityPhrasesRev)
        }

        public static var twp: DictGroup {
            DictGroup.fromStrings(DictData.TWVariantsRev, DictData.TWVariantsRevPhrases, DictData.TWPhrasesRev)
        }

        public static var jp: DictGroup {
            DictGroup.fromStrings(DictData.JPVariantsRev, DictData.JPShinjitaiCharacters, DictData.JPShinjitaiPhrases)
        }
    }

    public enum To {
        private static let tw2QualityPhrases = """
            應用程序網關	應用程式閘道
            鏡像文件	映像檔
            保存更改	儲存變更
            文件名	檔名
            文件系統	檔案系統
            文件描述符	檔案描述子
            函數調用	函式呼叫
            渲染管線	算繪管線
            內存分配	記憶體配置
            網絡棧	網路堆疊
            網絡適配器	網路介面卡
            """

        public static var cn: DictGroup {
            DictGroup.fromStrings(DictData.TSCharacters, DictData.TSPhrases)
        }

        public static var hk: DictGroup {
            DictGroup.fromStrings(DictData.HKVariants)
        }

        public static var tw: DictGroup {
            DictGroup.fromStrings(DictData.TWVariants)
        }

        public static var tw2: DictGroup {
            DictGroup.fromStrings(DictData.TWVariants, DictData.TWPhrasesCustom, tw2QualityPhrases)
        }

        public static var twp: DictGroup {
            DictGroup.fromStrings(DictData.TWVariants, DictData.TWPhrasesIT, DictData.TWPhrasesName, DictData.TWPhrasesOther)
        }

        public static var jp: DictGroup {
            DictGroup.fromStrings(DictData.JPVariants)
        }
    }

    public static var fromMap: [String: DictGroup] {
        [
            "cn": From.cn,
            "hk": From.hk,
            "tw": From.tw,
            "tw2": From.tw2,
            "twp": From.twp,
            "jp": From.jp,
        ]
    }

    public static var toMap: [String: DictGroup] {
        [
            "cn": To.cn,
            "hk": To.hk,
            "tw": To.tw,
            "tw2": To.tw2,
            "twp": To.twp,
            "jp": To.jp,
        ]
    }
}

public enum Presets {
    public enum Full {
        public static var locale: LocalePreset {
            OpenCC.preset
        }

        public static func converter(from: String, to: String) throws -> Converter {
            try converter(options: ConverterOptions(from: from, to: to))
        }

        public static func converter(options: ConverterOptions) throws -> Converter {
            try OpenCC.converterBuilder(localePreset: locale)(options)
        }
    }

    public enum Cn2t {
        public static var locale: LocalePreset {
            LocalePreset(
                from: ["cn": Locale.From.cn],
                to: [
                    "hk": Locale.To.hk,
                    "tw": Locale.To.tw,
                    "tw2": Locale.To.tw2,
                    "twp": Locale.To.twp,
                    "jp": Locale.To.jp,
                ]
            )
        }

        public static func converter(from: String, to: String) throws -> Converter {
            try converter(options: ConverterOptions(from: from, to: to))
        }

        public static func converter(options: ConverterOptions) throws -> Converter {
            try OpenCC.converterBuilder(localePreset: locale)(options)
        }
    }

    public enum T2cn {
        public static var locale: LocalePreset {
            LocalePreset(
                from: [
                    "hk": Locale.From.hk,
                    "tw": Locale.From.tw,
                    "tw2": Locale.From.tw2,
                    "twp": Locale.From.twp,
                    "jp": Locale.From.jp,
                ],
                to: ["cn": Locale.To.cn]
            )
        }

        public static func converter(from: String, to: String) throws -> Converter {
            try converter(options: ConverterOptions(from: from, to: to))
        }

        public static func converter(options: ConverterOptions) throws -> Converter {
            try OpenCC.converterBuilder(localePreset: locale)(options)
        }
    }
}

public enum OpenCC {
    public static var preset: LocalePreset {
        LocalePreset(from: Locale.fromMap, to: Locale.toMap)
    }

    public static func converter(from: String, to: String) throws -> Converter {
        try converter(options: ConverterOptions(from: from, to: to))
    }

    public static func converter(options: ConverterOptions) throws -> Converter {
        try converterBuilder(localePreset: preset)(options)
    }

    public static func converterBuilder(localePreset: LocalePreset) -> (ConverterOptions) throws -> Converter {
        { options in
            var dictGroups: [DictGroup] = []
            try addDictGroup(kind: "from", locale: options.from, map: localePreset.from, dictGroups: &dictGroups)
            try addDictGroup(kind: "to", locale: options.to, map: localePreset.to, dictGroups: &dictGroups)
            return converterFactory(dictGroups)
        }
    }

    public static func converterFactory(_ dictGroups: [DictGroup]) -> Converter {
        Converter(dictGroups: dictGroups)
    }

    public static func customConverter(_ dict: String) -> Converter {
        converterFactory([DictGroup([.raw(dict)])])
    }

    public static func customConverter(_ dict: [DictEntry]) -> Converter {
        converterFactory([DictGroup([.entries(dict)])])
    }

    private static func addDictGroup(
        kind: String,
        locale: String,
        map: [String: DictGroup],
        dictGroups: inout [DictGroup]
    ) throws {
        if locale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw OpenCCError.missingLocale(kind: kind)
        }

        if locale == "t" {
            return
        }

        guard let group = map[locale] else {
            throw OpenCCError.unknownLocale(kind: kind, locale: locale)
        }

        dictGroups.append(group)
    }
}

public final class HtmlConverter {
    private let converter: Converter
    private var document: XMLDocument
    private let originalXML: Data
    private let fromLangTag: String
    private let toLangTag: String

    public init(converter: Converter, xml: String, fromLangTag: String, toLangTag: String) throws {
        self.converter = converter
        self.fromLangTag = fromLangTag
        self.toLangTag = toLangTag

        do {
            document = try XMLDocument(xmlString: xml, options: [.nodePreserveWhitespace, .documentTidyXML])
            originalXML = document.xmlData(options: [.nodePreserveWhitespace])
        } catch {
            throw OpenCCError.xml(error.localizedDescription)
        }
    }

    public func convert() {
        if let root = document.rootElement() {
            convert(element: root, langMatched: false)
        }
    }

    public func restore() throws {
        do {
            document = try XMLDocument(data: originalXML, options: [.nodePreserveWhitespace, .documentTidyXML])
        } catch {
            throw OpenCCError.xml(error.localizedDescription)
        }
    }

    public func xmlString() -> String {
        document.xmlString(options: [])
    }

    private func convert(element: XMLElement, langMatched inheritedLangMatched: Bool) {
        if hasIgnoreClass(element) {
            return
        }

        var langMatched = inheritedLangMatched
        if let langAttr = element.attribute(forName: "lang") {
            let lang = langAttr.stringValue ?? ""
            if lang == fromLangTag {
                langMatched = true
                langAttr.stringValue = toLangTag
            } else if !lang.isEmpty {
                langMatched = false
            }
        }

        if langMatched {
            let tagName = element.name ?? ""
            if tagName.caseInsensitiveCompare("script") == .orderedSame
                || tagName.caseInsensitiveCompare("style") == .orderedSame {
                return
            }

            if tagName.caseInsensitiveCompare("meta") == .orderedSame {
                let name = element.attribute(forName: "name")?.stringValue
                if let name,
                    name.caseInsensitiveCompare("description") == .orderedSame
                        || name.caseInsensitiveCompare("keywords") == .orderedSame {
                    convertAttribute(named: "content", on: element)
                }
            } else if tagName.caseInsensitiveCompare("img") == .orderedSame {
                convertAttribute(named: "alt", on: element)
            } else if tagName.caseInsensitiveCompare("input") == .orderedSame {
                let type = element.attribute(forName: "type")?.stringValue
                if type?.caseInsensitiveCompare("button") == .orderedSame {
                    convertAttribute(named: "value", on: element)
                }
            }
        }

        for child in element.children ?? [] {
            if let childElement = child as? XMLElement {
                convert(element: childElement, langMatched: langMatched)
            } else if child.kind == .text, langMatched, let value = child.stringValue {
                child.stringValue = converter.convert(value)
            }
        }
    }

    private func convertAttribute(named name: String, on element: XMLElement) {
        guard let attribute = element.attribute(forName: name), let value = attribute.stringValue else {
            return
        }

        attribute.stringValue = converter.convert(value)
    }

    private func hasIgnoreClass(_ element: XMLElement) -> Bool {
        guard let classValue = element.attribute(forName: "class")?.stringValue else {
            return false
        }

        return classValue.split(whereSeparator: { $0.isWhitespace }).contains("ignore-opencc")
    }
}
