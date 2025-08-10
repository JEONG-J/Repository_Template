//
//  KakaoAuthService.swift
//  VINNY
//
//  Created by 소민준 on 8/6/25.
//


import KakaoSDKUser
import KakaoSDKAuth
import Foundation

final class KakaoAuthService {
    static let shared = KakaoAuthService()
    private init() {}

    func loginAndGetAccessToken() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let token = oauthToken?.accessToken {
                        continuation.resume(returning: token)
                    } else {
                        continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access Token 가져오기 실패"] ))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let token = oauthToken?.accessToken {
                        continuation.resume(returning: token)
                    } else {
                        continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access Token 가져오기 실패"] ))
                    }
                }
            }
        }
    }
}
