//
//  ProfileCoordinator.swift
//  Profile
//
//  Created by Sangjin Lee
//

import AppCore

public protocol ProfileCoordinator: Coordinator {
    var delegate: ProfileCoordinatorDelegate? { get set }
}
