// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [ .library( name: "LogKit", targets: ["LogKit"]), ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", branch: "main")
    ],
    targets: [
      .target(name: "LogKit",
              dependencies: [
                  .product(name: "Logging", package: "swift-log")
              ]),
      .testTarget(
          name: "LogKitTests",
          dependencies: [ .target(name: "LogKit"), ]
      )
    ],
    swiftLanguageModes: [ .v6 ]
)

