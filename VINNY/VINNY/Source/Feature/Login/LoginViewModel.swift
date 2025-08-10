//
//  LoginViewModel.swift
//  VINNY
//
//  Created by 소민준 on 8/7/25.
//


import SwiftUI
import Moya

extension MoyaProvider {
    func request(_ target: Target) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    /// 카카오 로그인 → 서버 로그인 요청 → JWT 저장
    func loginWithKakao() async -> Bool {
        do {
            // 카카오 SDK로부터 accessToken 받기
            let kakaoAccessToken = try await KakaoAuthService.shared.loginAndGetAccessToken()
            let requestDTO = LoginRequestDTO(accessToken: kakaoAccessToken)

            // 우리 서버에 로그인 요청
            
            let response = try await container
                .useCaseProvider
                .authUseCase
                .request(.login(dto: requestDTO)) // 응답은 `Response` 타입임
            if let request = response.request {
                print("요청 URL: \(request.url?.absoluteString ?? "nil")")
                print("요청 Method: \(request.httpMethod ?? "nil")")
                print("요청 Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "body 없음")")
            }

            print("응답 상태 코드: \(response.statusCode)")
            print("응답 원문:\n\(String(data: response.data, encoding: .utf8) ?? "디코딩 불가")")

            let decoded = try JSONDecoder().decode(LoginResponseDTO.self, from: response.data)

            TokenManager.shared.saveTokens(
                accessToken: decoded.result.accessToken,
                refreshToken: decoded.result.refreshToken
            )
            if decoded.result.isNewUser {
                container.onboardingSelection.reset()             
                container.navigationRouter.push(to: .CategoryView)
            } else {
                container.navigationRouter.push(to: .VinnyTabView)
            }

            print(" 로그인 성공. isNewUser: \(decoded.result.isNewUser)")
            return true
        } catch {
            print("로그인 실패: \(error)")
            return false
        }
    }
}
