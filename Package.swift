// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BarrageRendererTV",
    platforms: [
        .iOS(.v9),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "BarrageRendererTV",
            targets: ["BarrageRendererTV"]
        )
    ],
    targets: [
        .target(
            name: "BarrageRendererTV",
            dependencies: [],
            path: "BarrageRenderer",
            cSettings: [
                .headerSearchPath("BarrageEngine"),
                .headerSearchPath("BarrageSprite"),
                .headerSearchPath("BarrageLoader")
            ]
        )
    ]
)
