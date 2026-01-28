// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyBrowser",
    platforms: [
        .macOS(.v12) // Targeting macOS Monterey or later for modern SwiftUI/WKWebView features
    ],
    products: [
        .executable(name: "MyBrowser", targets: ["MyBrowser"])
    ],
    targets: [
        .executableTarget(
            name: "MyBrowser",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
