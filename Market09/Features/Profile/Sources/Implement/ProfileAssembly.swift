//
//  ProfileAssembly.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Domain
import Profile
import Shared_DI

public final class ProfileAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(ProfileReactor.Factory.self) { r in
            ProfileReactor.Factory(dependency: .init(
                signOutUseCase: r.resolve(),
                deleteAccountUseCase: r.resolve(),
                userStore: r.resolve()
            ))
        }
        .inObjectScope(.graph)

        container.register(ProfileViewController.Factory.self) { r in
            ProfileViewController.Factory(dependency: .init(
                reactor: r.resolve(ProfileReactor.Factory.self)!.create()
            ))
        }
        .inObjectScope(.graph)

        container.register(ProfileCoordinator.self) { (r, navigationController: UINavigationController) in
            ProfileCoordinatorImpl(
                navigationController: navigationController,
                viewController: r.resolve(ProfileViewController.Factory.self)!.create()
            )
        }
        .inObjectScope(.graph)
    }
}
