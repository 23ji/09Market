//
//  Project.swift
//  Calendar
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Calendar",
    targets: Project.interfaceTargets(
        name: "Calendar",
        dependencies: [
            .module(.core),
        ]
    ) + Project.implementTargets(
        name: "Calendar",
        dependencies: [
          .module(.core),
          .module(.domain),
          .module(.sharedDI),
          .module(.sharedReactiveX),
          .external(name: "Kingfisher")
        ]
    )
)
