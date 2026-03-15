//
//  LoginCoordinatorImpl.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Login
import Shared_DI
import Shared_ReactiveX

final class LoginCoordinatorImpl: LoginCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController
    
    
    // MARK: - Delegate
    
    public weak var delegate: LoginCoordinatorDelegate?
    
    
    // MARK: - Reactor
    
    private let viewController: LoginViewController
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Init
    
    public init(
        navigationController: UINavigationController,
        viewController: LoginViewController
    ) {
        self.navigationController = navigationController
        self.viewController = viewController
    }
    
    
    // MARK: - Login
    
    public func start() {
        guard let reactor = self.viewController.reactor else { return }

        // 로그인 성공 시 delegate 호출
        reactor.state.map(\.isLoginCompleted)
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.delegate?.loginDidComplete()
            })
            .disposed(by: self.disposeBag)

        self.navigationController.pushViewController(self.viewController, animated: true)
    }
}
