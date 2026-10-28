// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "dlm_platform",
    platforms: [
        .macOS("13.0")
    ],
    products: [
        .library(name: "dlm-platform", targets: ["dlm_platform"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "dlm_platform",
            dependencies: []
        )
    ]
)
