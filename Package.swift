// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Unrealm",
    products: [
        .library(name: "UnrealmObjC", targets: ["UnrealmObjC"]),
        .library(name: "Unrealm", targets: ["Unrealm", "UnrealmObjC"])
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-cocoa.git", from: "3.17.3"),
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.1.0")
    ],
    targets: [
        .target(
            name: "UnrealmObjC",
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
