//
//  AuthCoordinator.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import AppCore

public protocol AuthCoordinator: Coordinator {
    var delegate: AuthCoordinatorDelegate? { get set }
}
