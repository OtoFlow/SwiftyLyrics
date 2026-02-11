import ProjectDescription

let project = Project(
    name: "SwiftyLyricsExample",
    packages: [
        .local(path: "../")
    ],
    targets: [
        .target(
            name: "SwiftyLyricsExample",
            destinations: [.iPhone, .iPad, .macCatalyst, .mac],
            product: .app,
            bundleId: "com.foyoodo.SwiftyLyricsExample",
            deploymentTargets: .multiplatform(iOS: "17.0", macOS: "14.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "SwiftyLyricsExample/Sources",
                "SwiftyLyricsExample/Resources",
            ],
            dependencies: [
                .package(product: "LyricLabel"),
            ]
        ),
    ]
)
