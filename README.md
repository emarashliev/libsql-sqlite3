# libsql-sqlite3

[![Swift Version](https://img.shields.io/badge/Swift-5.3+-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**libsql-sqlite3** is a Swift package that provides a native wrapper around the [libSQL](https://github.com/tursodatabase/libsql) fork of SQLite. This package delivers the power of libSQL – a community-driven, open-contribution fork of SQLite – as a pre-built binary (xcframework).

> libSQL is designed to extend SQLite’s capabilities while maintaining full compatibility with its file format and C API. With this package, you can harness those improvements directly in your Swift applications.

## Requirements

- **iOS:** 11.0 or later (adjustable in Package.swift)
- **Swift:** 5.3 or later
- **Xcode:** 12 or later
## ⚠️ Does not support iOS x86_64 simulator
## Installation
### Using Xcode (Swift Package Manager)

1. Open your Xcode project.
2. Navigate to **File > Swift Packages > Add Package Dependency…**
3. Enter the repository URL:  
   `https://github.com/emarashliev/libsql-sqlite3.git`
4. Choose your version rule (e.g., “Up to Next Major” starting from 1.0.0) and finish the setup.

### Adding via Package.swift

Include the package dependency in your Package.swift file as shown below:

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/emarashliev/libsql-sqlite3.git", branch: "main")
    ],
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["SQLite3"]
        )
    ]
)
