//
//  LoginViewModel.swift
//  VINNY
//
//  Created by 소민준 on 8/7/25.
//


import SwiftUI
import Moya
import Alamofire

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
    
    func loginWithApple() async -> Bool {
        do {
            // 1) 최초 토큰 발급
            var (code, idToken) = try await AppleAuthService.shared.signIn()   // :contentReference[oaicite:1]{index=1}

            // 2) 최대 1회 재시도
            for attempt in 0...1 {
                do {
                    let dto = AppleLoginRequestDTO(authorizationCode: code, identityToken: idToken) // platform "ios" 포함됨
                    let response = try await container.useCaseProvider.authUseCase.request(.appleLogin(dto: dto)) // :contentReference[oaicite:2]{index=2}

                    if (200..<300).contains(response.statusCode) {
                        // 공통 래퍼로 파싱
                        let env = try JSONDecoder().decode(ApiEnvelope<LoginResult>.self, from: response.data) // :contentReference[oaicite:3]{index=3}
                        TokenManager.shared.saveTokens(accessToken: env.result.accessToken, refreshToken: env.result.refreshToken)
                        if env.result.isNewUser {
                            container.onboardingSelection.reset()
                            container.navigationRouter.push(to: .CategoryView)
                        } else {
                            container.navigationRouter.push(to: .VinnyTabView)
                        }
                        return true
                    } else {
                        // 에러 바디가 문자열 result일 수 있으므로 별도 처리
                        struct ErrorEnvelope: Decodable { let isSuccess: Bool; let code: String; let message: String; let result: String; let timestamp: String }
                        let err = try? JSONDecoder().decode(ErrorEnvelope.self, from: response.data)
                        throw NSError(domain: "AppleLogin", code: response.statusCode,
                                      userInfo: [NSLocalizedDescriptionKey: err?.result ?? "로그인 실패"])
                    }

                } catch {
                    // 네트워크 끊김(-1005)이면 1회만 토큰 재발급 후 재시도
                    if attempt == 0, error.isNetworkConnectionLost {
                        await asyncAfter(0.6)
                        (code, idToken) = try await AppleAuthService.shared.signIn() // 새 토큰으로 재시도
                        continue
                    }
                    throw error
                }
            }
            return false
        } catch {
            print("Apple 로그인 실패:", error)
            return false
        }
    }
}

private extension Error {
    var isNetworkConnectionLost: Bool {
        if let af = self as? AFError,
           case .sessionTaskFailed(let underlying) = af,
           (underlying as? URLError)?.code == .networkConnectionLost { return true }
        if let urlErr = self as? URLError, urlErr.code == .networkConnectionLost { return true }
        return false
    }
}

// 파일 하단 어디든
private func asyncAfter(_ seconds: TimeInterval) async {
    await withCheckedContinuation { cont in
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
            cont.resume()
        }
    }
}
