//
//  Project.swift
//  Domain
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Domain",
    targets: Project.interfaceTargets(
        name: "Domain",
        dependencies: [
            .module(.core),
        ]
    ) + Project.implementTargets(
        name: "Domain",
        dependencies: [
            .module(.core),
            .external(name: "Swinject"),
        ]
    )
)
