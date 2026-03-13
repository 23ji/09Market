//
//  LoginCoordinator.swift
//  Login
//
//  Created by Sangjin Lee
//

import AppCore

public protocol LoginCoordinator: Coordinator {
    var delegate: LoginCoordinatorDelegate? { get set }
}
