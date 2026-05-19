import OpenCCSwift

let text = "鼠标、软件、打印机和服务器都连接到计算机网络。"

print("原文：\(text)")
print()

for target in ["t", "tw", "tw2", "twp", "hk", "jp"] {
    let converter = try OpenCC.converter(from: "cn", to: target)
    print("cn -> \(target.padding(toLength: 3, withPad: " ", startingAt: 0)) \(converter.convert(text))")
}

print()
print("選擇建議：只轉字形用 t；臺灣產品介面多半用 tw2；面向香港使用者可用 hk。")
