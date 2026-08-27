// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ImaotoBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ImaotoBar", targets: ["ImaotoBar"])
    ],
    targets: [
        .executableTarget(
            name: "ImaotoBar",
            path: "Sources/NowPlayingBar",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
