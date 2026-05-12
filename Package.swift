// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThermalFans",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ThermalFans",
            path: "Sources/ThermalFans",
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("AppKit"),
            ]
        )
    ]
)
