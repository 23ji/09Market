//
//  InfluencerRepository.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol InfluencerRepository {
    /// 인플루언서 등록
    /// - Parameters:
    ///   - username: 인플루언서 ID
    /// - Throws: `AppError.network(.conflict)` 이미 등록된 경우
    func registerInfluencer(_ username: String) async throws
}
