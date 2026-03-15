//
//  UserMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import AppCore

enum UserMapper {
    static func toUserEntity(_ response: UserResponse) -> User {
        return User(
            id: response.id,
            nickname: response.nickname,
            profileUrl: response.profileUrl,
            provider: AuthProvider(rawValue: response.provider) ?? .google
        )
    }
}
