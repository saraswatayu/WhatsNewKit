// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "WhatsNewKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "WhatsNewKit",
            targets: ["WhatsNewKit"]
        )
    ],
    targets: [
        .target(
            name: "WhatsNewKit",
            path: "Sources"
        ),
        .testTarget(
            name: "WhatsNewKitTests",
            dependencies: ["WhatsNewKit"],
            path: "Tests"
        )
    ]
)
