// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "JustPomodoro",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "JustPomodoro",
            targets: ["JustPomodoro"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "JustPomodoro",
            dependencies: [],
            path: "Just Pomodoro",
            exclude: ["Resources/Info.plist"],
            resources: [
                .process("Resources/Assets.xcassets")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
