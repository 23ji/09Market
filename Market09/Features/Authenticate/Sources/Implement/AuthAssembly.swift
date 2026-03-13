//
//  AuthAssembly.swift
//  AuthenticateImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Authenticate
import Domain
import Shared_DI

public final class AuthAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(AuthReactor.Factory.self) { r in
            AuthReactor.Factory(dependency: .init(
                checkAuthOnLaunchUseCase: r.resolve()
            ))
        }
        .inObjectScope(.graph)

        container.register(AuthCoordinator.self) { (r, navigation: UINavigationController) in
            AuthCoordinatorImpl(
                navigationController: navigation,
                authReactor: r.resolve(AuthReactor.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)
    }
}
