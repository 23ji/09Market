//
//  Project.swift
//  Login
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Login",
    targets: Project.interfaceTargets(
        name: "Login",
        dependencies: [
            .module(.core),
        ]
    ) + Project.implementTargets(
        name: "Login",
        dependencies: [
            .module(.core),
            .module(.domain),
            .module(.sharedReactiveX),
            .external(name: "Swinject"),
            .external(name: "GoogleSignIn"),
        ]
    )
)
