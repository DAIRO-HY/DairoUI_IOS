// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DairoUI_IOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DairoUI_IOS",
            targets: ["DairoUI_IOS"]),
    ],
    
    //该Package要引入的外部依赖
    dependencies:[
        //.package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.3.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DairoUI_IOS",
            resources: [
                // 递归拷贝整个资源文件夹
                .process("Resources")
            ]
        ),
    ]
)
