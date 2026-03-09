//
//  LoginAssembly.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import UIKit

import Core
import Domain
import Login
import Shared_DI

public final class LoginAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(LoginReactor.Factory.self) { r in
            LoginReactor.Factory(dependency: .init(
                signInWithIdTokenUseCase: r.resolve()
            ))
        }
        .inObjectScope(.graph)
        
        container.register(LoginViewController.Factory.self) { r in
            LoginViewController.Factory(dependency: .init(
                reactor: r.resolve(LoginReactor.Factory.self)!.create()
            ))
        }
        .inObjectScope(.graph)

        container.register(LoginCoordinator.self) { (r, navigation: UINavigationController) in
            LoginCoordinatorImpl(
                navigationController: navigation,
                viewController: r.resolve(LoginViewController.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)
    }
}
