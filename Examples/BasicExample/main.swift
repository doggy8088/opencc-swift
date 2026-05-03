import OpenCCSwift

let converter = try OpenCC.converter(from: "cn", to: "tw2")
print(converter.convert("汉语"))
