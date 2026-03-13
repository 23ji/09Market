//
//  CheckAuthOnLaunchUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import AppCore

public protocol CheckAuthOnLaunchUseCase {
    func execute() async throws -> AuthState
}
