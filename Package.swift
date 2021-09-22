// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Unrealm",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "UnrealmObjC", targets: ["UnrealmObjC"]),
        .library(name: "Unrealm", targets: ["Unrealm", "UnrealmObjC"])
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-cocoa.git", from: "10.15.1"),
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.2.2")
    ],
    targets: [
        .target(
            name: "UnrealmObjC",
            dependencies: ["Realm", "RealmSwift"],
            path: "Unrealm/Classes/ObjC"
        ),
        .target(
            name: "Unrealm",
            dependencies: ["UnrealmObjC", "Realm", "RealmSwift", "Runtime"],
            path: "Unrealm/Classes/Swift"
        )
    ],
    swiftLanguageVersions: [.v5]
)
