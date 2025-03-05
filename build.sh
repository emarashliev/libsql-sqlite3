git clone --branch vector --depth 1 https://github.com/tursodatabase/libsql.git

mkdir bld
cd bld
../libsql/libsql-sqlite3/configure
make

# Build for iOS (arm64)
xcrun --sdk iphoneos clang -arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -dynamiclib sqlite3.c -o libsqlite3_arm64.dylib -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA -install_name @rpath/libsqlite3_arm64.dylib

# Build for iOS Simulator (arm64)
xcrun --sdk iphonesimulator clang -arch arm64 -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -dynamiclib sqlite3.c -o libsqlite3_sim_arm64.dylib -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA -install_name @rpath/libsqlite3_sim_arm64.dylib

cd ..
xcodebuild -create-xcframework \
    -library bld/libsqlite3_arm64.dylib \
    -headers bld/sqlite3.h \
    -library bld/libsqlite3_sim_arm64.dylib \
    -headers bld/sqlite3.h \
    -output sqlite3.xcframework

rm -rf bld/
rm -rf libsql/ 