// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "hotkey_manager_macos",
    platforms: [
        .macOS("13.0")
    ],
    products: [
        .library(name: "hotkey-manager-macos", targets: ["hotkey_manager_macos"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "hotkey_manager_macos",
            dependencies: []
        )
    ]
)
