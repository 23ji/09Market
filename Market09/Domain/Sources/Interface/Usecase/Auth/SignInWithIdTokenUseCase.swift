//
//  SignInWithIdTokenUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import AppCore

public protocol SignInWithIdTokenUseCase {
    func execute(provider: AuthProvider, idToken: String, nonce: String?) async throws -> AuthToken
}
