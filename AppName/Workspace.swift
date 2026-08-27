import ProjectDescription

let workspace = Workspace(
    name: "AppName",
    projects: [
        ".",
        "Core/*",
        "Features/*",
        "AppNameWidget",
        "AppNameWatchApp",
    ]
)
