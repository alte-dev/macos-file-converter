// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AlteFileConverter",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "AlteFileConverter", targets: ["AlteFileConverter"])
    ],
    targets: [
        .executableTarget(
            name: "AlteFileConverter",
            path: "Sources"
        )
    ]
)
