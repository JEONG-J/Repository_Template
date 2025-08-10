//
//  TokenManager.swift
//  VINNY
//
//  Created by 소민준 on 8/7/25.
//


//  TokenManager.swift
//  VINNY
//
//  Created by 리팩토링 on 2025/08/06.
//

import Foundation
import Moya

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    // MARK: - JWT 유효성 검사 및 필요 시 재발급
    func validateAndRefreshTokenIfNeeded() async -> Bool {
        guard let accessToken = KeychainHelper.shared.get(forKey: "accessToken"),
              let expirationDate = JWTHelper.shared.getTokenExpirationDate(from: accessToken) else {
            print("accessToken 없음 또는 파싱 실패")
            return false
        }

        let timeRemaining = expirationDate.timeIntervalSinceNow
        print("TokenManager: 남은 시간 \(timeRemaining / 60)분")

        if timeRemaining <= 0 {
            print("accessToken 만료 → refreshToken으로 재발급 시도")
            return await refreshToken()
        } else if timeRemaining <= 10 * 60 {
            print("accessToken 만료 임박 → 선제적으로 refreshToken 사용")
            return await refreshToken()
        } else {
            return true
        }
    }

    // MARK: - 토큰 재발급
    func refreshToken() async -> Bool {
        guard let refreshToken = KeychainHelper.shared.get(forKey: "refreshToken") else {
            print("refreshToken 없음 → 로그인 필요")
            return false
        }

        let reissueRequest = ReissueTokenRequestDTO(refreshToken: refreshToken)
        let manager = DefaultNetworkManager<AuthAPITarget>()

        do {
            let response: ReissueTokenResponseDTO = try await withCheckedThrowingContinuation { continuation in
                manager.request(
                    target: .reissueToken(dto: reissueRequest),
                    decodingType: ReissueTokenResponseDTO.self
                ) { result in
                    switch result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }

            KeychainHelper.shared.save(response.accessToken, forKey: "accessToken")
            KeychainHelper.shared.save(response.refreshToken, forKey: "refreshToken")

            print("토큰 재발급 성공 ✅")
            return true
        } catch {
            print("토큰 재발급 실패 ❌: \(error)")
            KeychainHelper.shared.delete(forKey: "accessToken")
            KeychainHelper.shared.delete(forKey: "refreshToken")
            return false
        }
    }
    func saveTokens(accessToken: String, refreshToken: String) {
            KeychainHelper.shared.save(accessToken, forKey: "accessToken")
            KeychainHelper.shared.save(refreshToken, forKey: "refreshToken")
        }
    
}

