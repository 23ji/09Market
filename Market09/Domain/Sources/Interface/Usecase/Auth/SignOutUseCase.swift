//
//  SignOutUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import AppCore

public protocol SignOutUseCase {
    func execute(provider: AuthProvider) async throws
}
