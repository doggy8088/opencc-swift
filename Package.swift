// swift-tools-version: 6.3
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
            path: "Examples/BasicExample"
        ),
        .executableTarget(
            name: "CustomExample",
            dependencies: ["OpenCCSwift"],
            path: "Examples/CustomExample"
        ),
        .executableTarget(
            name: "HtmlExample",
            dependencies: ["OpenCCSwift"],
            path: "Examples/HtmlExample"
        ),
        .testTarget(
            name: "OpenCCSwiftTests",
            dependencies: ["OpenCCSwift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
