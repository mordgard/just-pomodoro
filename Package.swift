// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "JustPomodoro",
    platforms: [
        .macOS("15.0")
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
                .process("Just Pomodoro/Resources/Assets.xcassets")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
