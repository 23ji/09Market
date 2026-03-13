//
//  AuthState.swift
//  Domain
//
//  Created by Sangjin Lee
//

import AppCore

public enum AuthState {
    case anonymous
    case authenticated(User)
    case unauthenticated
}
