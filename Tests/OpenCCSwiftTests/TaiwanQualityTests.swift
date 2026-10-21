import Foundation
import Testing
@testable import OpenCCSwift

@Test func taiwanQualityAndIdempotence() throws {
    let file = Bundle.module.url(forResource: "taiwan-quality", withExtension: "tsv")!
    let cases = try String(contentsOf: file, encoding: .utf8)
    for locale in ["tw2", "twp"] {
        let c = try OpenCC.converter(from: "cn", to: locale)
        for line in cases.split(separator: "\n") {
            let parts = line.split(separator: "\t").map(String.init)
            if parts[0] != "both" && parts[0] != locale { continue }
            #expect(c.convert(parts[1]) == parts[2])
            #expect(c.convert(parts[2]) == parts[2])
            #expect(!parts[2].contains("賬") && !parts[2].contains("羣"))
        }
    }
}
