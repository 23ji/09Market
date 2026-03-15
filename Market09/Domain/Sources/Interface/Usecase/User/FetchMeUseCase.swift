//
//  FetchMeUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import AppCore

public protocol FetchMeUseCase {
    func execute() async throws -> User?
}
