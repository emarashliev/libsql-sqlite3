#!/bin/bash
#
# SQLite3 iOS Build Script
# Builds SQLite3 libraries with vector extension support for iOS platforms
#

set -e  # Exit immediately if a command exits with non-zero status

# Configuration variables
REPO_URL="https://github.com/tursodatabase/libsql.git"
BRANCH="vector"
BUILD_DIR="bld"
OUTPUT_FRAMEWORK="sqlite3.xcframework"
SQLITE_FLAGS="-DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA"

# Command line options
CLEAN_ONLY=0
VERBOSE=0
SKIP_CLONE=0

# Log messages with color
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1 >&2"
}

show_help() {
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Build SQLite3 with vector extensions for iOS."
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -c, --clean-only  Clean build artifacts without building"
    echo "  -v, --verbose     Enable verbose output"
    echo "  -s, --skip-clone  Skip repository cloning (use existing)"
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean-only)
            CLEAN_ONLY=1
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -s|--skip-clone)
            SKIP_CLONE=1
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Enable verbose output if requested
if [[ $VERBOSE -eq 1 ]]; then
    set -x  # Print commands and their arguments as they are executed
fi

# Function to clean up build artifacts
clean_up() {
    log_info "Cleaning up build artifacts..."
    
    # Remove build directory if it exists
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
        log_info "Removed build directory: $BUILD_DIR"
    fi
    
    # Remove libsql directory if it exists
    if [[ -d "libsql" ]]; then
        rm -rf "libsql"
        log_info "Removed source directory: libsql"
    fi
    
    # Remove XCFramework if it exists
    if [[ -d "$OUTPUT_FRAMEWORK" ]]; then
        rm -rf "$OUTPUT_FRAMEWORK"
        log_info "Removed framework: $OUTPUT_FRAMEWORK"
    fi
    
    log_success "Cleanup completed"
}

# Clean up and exit if clean-only option was provided
if [[ $CLEAN_ONLY -eq 1 ]]; then
    clean_up
    exit 0
fi

# Clone repository if needed
if [[ $SKIP_CLONE -eq 0 ]]; then
    log_info "Cloning libsql repository (branch: $BRANCH)..."
    if [[ -d "libsql" ]]; then
        log_info "libsql directory already exists, removing it first..."
        rm -rf "libsql"
    fi
    git clone --branch "$BRANCH" --depth 1 "$REPO_URL" || {
        log_error "Failed to clone repository"
        exit 1
    }
    log_success "Repository cloned successfully"
else
    if [[ ! -d "libsql" ]]; then
        log_error "libsql directory not found. Cannot skip cloning."
        exit 1
    fi
    log_info "Skipping repository clone as requested"
fi

# Create and enter build directory
log_info "Creating build directory..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || {
    log_error "Failed to enter build directory"
    exit 1
}

# Configure the build
log_info "Configuring build..."
../libsql/libsql-sqlite3/configure || {
    log_error "Configuration failed"
    exit 1
}

# Build the base version
log_info "Building base version..."
make || {
    log_error "Build failed"
    exit 1
}

# Build for iOS (arm64)
log_info "Building for iOS (arm64)..."
IOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
if [[ -z "$IOS_SDK_PATH" ]]; then
    log_error "Failed to get iOS SDK path"
    exit 1
fi

xcrun --sdk iphoneos clang -arch arm64 -isysroot "$IOS_SDK_PATH" -dynamiclib \
    sqlite3.c -o libsqlite3_arm64.dylib $SQLITE_FLAGS \
    -install_name @rpath/libsqlite3_arm64.dylib || {
    log_error "iOS arm64 build failed"
    exit 1
}
log_success "iOS arm64 build completed"

# Build for iOS Simulator (arm64)
log_info "Building for iOS Simulator (arm64)..."
SIM_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
if [[ -z "$SIM_SDK_PATH" ]]; then
    log_error "Failed to get iOS Simulator SDK path"
    exit 1
fi

xcrun --sdk iphonesimulator clang -arch arm64 -isysroot "$SIM_SDK_PATH" -dynamiclib \
    sqlite3.c -o libsqlite3_sim_arm64.dylib $SQLITE_FLAGS \
    -install_name @rpath/libsqlite3_sim_arm64.dylib || {
    log_error "iOS Simulator arm64 build failed"
    exit 1
}
log_success "iOS Simulator arm64 build completed"

# Return to the root directory
cd ..

# Create XCFramework
log_info "Creating XCFramework..."
xcodebuild -create-xcframework \
    -library "$BUILD_DIR/libsqlite3_arm64.dylib" \
    -headers "$BUILD_DIR/sqlite3.h" \
    -library "$BUILD_DIR/libsqlite3_sim_arm64.dylib" \
    -headers "$BUILD_DIR/sqlite3.h" \
    -output "$OUTPUT_FRAMEWORK" || {
    log_error "XCFramework creation failed"
    exit 1
}
log_success "XCFramework created at: $OUTPUT_FRAMEWORK"

# Clean up build directory but keep the framework
log_info "Cleaning up build artifacts..."
rm -rf "$BUILD_DIR/"
rm -rf "libsql/"
log_success "Build completed successfully!"

# Verify the output
if [[ -d "$OUTPUT_FRAMEWORK" ]]; then
    log_success "Generated $OUTPUT_FRAMEWORK is ready to use"
else
    log_error "Failed to generate $OUTPUT_FRAMEWORK"
    exit 1
fi 