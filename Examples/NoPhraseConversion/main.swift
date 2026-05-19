import OpenCCSwift

let text = "鼠标和软件可以连接到计算机网络。"
let shapeOnly = try OpenCC.converter(from: "cn", to: "t")
let taiwanWords = try OpenCC.converter(from: "cn", to: "tw2")

print("原文：\(text)")
print("只轉字形 cn -> t：\(shapeOnly.convert(text))")
print("臺灣詞彙 cn -> tw2：\(taiwanWords.convert(text))")
print()
print("差異：cn -> t 保留原本詞彙；cn -> tw2 會轉成臺灣慣用詞。")
