// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenCCSwift",
    products: [
        .library(
            name: "OpenCCSwift",
            targets: ["OpenCCSwift"]
        ),
        .executable(name: "BasicExample", targets: ["BasicExample"]),
        .executable(name: "NoPhraseConversion", targets: ["NoPhraseConversion"]),
        .executable(name: "LocaleDifferences", targets: ["LocaleDifferences"]),
        .executable(name: "CustomExample", targets: ["CustomExample"]),
        .executable(name: "HtmlExample", targets: ["HtmlExample"]),
    ],
    targets: [
        .target(
            name: "OpenCCSwift"
        ),
        .executableTarget(
            name: "BasicExample",
            dependencies: ["OpenCCSwift"],
            path: "Examples/BasicExample",
            exclude: ["README.md"]
        ),
        .executableTarget(
            name: "NoPhraseConversion",
            dependencies: ["OpenCCSwift"],
            path: "Examples/NoPhraseConversion",
            exclude: ["README.md"]
        ),
        .executableTarget(
            name: "LocaleDifferences",
            dependencies: ["OpenCCSwift"],
            path: "Examples/LocaleDifferences",
            exclude: ["README.md"]
        ),
        .executableTarget(
            name: "CustomExample",
            dependencies: ["OpenCCSwift"],
            path: "Examples/CustomExample",
            exclude: ["README.md"]
        ),
        .executableTarget(
            name: "HtmlExample",
            dependencies: ["OpenCCSwift"],
            path: "Examples/HtmlExample",
            exclude: ["README.md"]
        ),
        .testTarget(
            name: "OpenCCSwiftTests",
            dependencies: ["OpenCCSwift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
