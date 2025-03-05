// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "libsql-sqlite3",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "SQLite3", targets: ["SQLite3"]),
    ],
    targets: [
        .binaryTarget(
            name: "sqlite3",
            path: "sqlite3.xcframework"
        ),
        .target(
            name: "SQLite3",
            dependencies: ["sqlite3"],
            publicHeadersPath: "include"
        ),
    ]
)