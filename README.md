# libsql-sqlite3

[![Swift Version](https://img.shields.io/badge/Swift-5.3+-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**libsql-sqlite3** is a Swift package that provides a native wrapper around the [libSQL](https://github.com/tursodatabase/libsql) fork of SQLite. This package delivers the power of libSQL – a community-driven, open-contribution fork of SQLite – as a pre-built binary (xcframework).

> libSQL is designed to extend SQLite's capabilities while maintaining full compatibility with its file format and C API. With this package, you can harness those improvements directly in your Swift applications.

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
4. Choose your version rule (e.g., "Up to Next Major" starting from 1.0.0) and finish the setup.

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

```

# SQLite3 iOS Build Script Documentation

## Overview

This script builds SQLite3 libraries with vector extension support for iOS platforms. It creates a universal XCFramework that can be used in iOS applications, supporting both device and simulator architectures.

## Features

- Clones the libsql repository with vector extensions
- Builds SQLite3 with common extensions (FTS5, JSON1, RTREE, COLUMN_METADATA)
- Creates a universal XCFramework for iOS (arm64) and iOS Simulator (arm64)
- Provides clean-up functionality for build artifacts
- Supports verbose mode for debugging

## Prerequisites

- macOS development environment
- Xcode command-line tools
- Git

## Usage

```bash
./build.sh [options]
```

### Options

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help message |
| `-c`, `--clean-only` | Clean build artifacts without building |
| `-v`, `--verbose` | Enable verbose output |
| `-s`, `--skip-clone` | Skip repository cloning (use existing) |

## Build Process

The script performs the following steps:

1. **Repository Cloning**: Clones the libsql repository from GitHub, specifically the "vector" branch
2. **Building**: 
   - Configures and builds the base SQLite3 version
   - Builds for iOS device (arm64) with required flags
   - Builds for iOS Simulator (arm64) with required flags
3. **XCFramework Creation**: Packages the libraries into a universal XCFramework
4. **Cleanup**: Removes temporary build artifacts

## Output

The script generates `sqlite3.xcframework` in the current directory, which includes:
- Dynamic libraries for iOS (arm64) and iOS Simulator (arm64)
- Headers for SQLite3

## Configuration

The script uses these main configuration variables:

```bash
REPO_URL="https://github.com/tursodatabase/libsql.git"
BRANCH="vector"
BUILD_DIR="bld"
OUTPUT_FRAMEWORK="sqlite3.xcframework"
SQLITE_FLAGS="-DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA"
```

## Examples

### Standard Build

```bash
./build.sh
```

### Clean Before Building

```bash
./build.sh --clean-only
./build.sh
```

### Verbose Output

```bash
./build.sh --verbose
```

### Using Existing Repository

```bash
./build.sh --skip-clone
```

## Troubleshooting

If you encounter issues:

1. Check that Xcode and command-line tools are installed
2. Ensure you have internet access for repository cloning
3. Run in verbose mode for detailed output: `./build.sh --verbose`
4. Clean build artifacts and try again: `./build.sh --clean-only && ./build.sh`

## License

The build script itself is provided as-is. SQLite3 is in the public domain.
