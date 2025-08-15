//
//  SplashView.swift
//  VINNY
//
//  Created by 소민준 on 8/10/25.
//

import SwiftUI
import Moya

/// 앱 첫 진입 화면: 로고 노출 + /api/auth/session 호출 후 분기
struct SplashView: View {
    @EnvironmentObject var container: DIContainer
    @StateObject private var vm: SplashViewModel
    
    init(container: DIContainer) {
        _vm = StateObject(wrappedValue: SplashViewModel(container: container))
    }
    
    var body: some View {
        ZStack {
            Color.backRootRegular.ignoresSafeArea()
            Image("vinnylogo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 100)
        }
        .task {
            await vm.bootstrap()
        }
    }
}



@MainActor
final class SplashViewModel: ObservableObject {
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    /// /session → (필요 시) /reissue → /session → route
    
    func bootstrap() async {
        let status = await fetchSessionStatus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.route(by: status ?? "LOGIN")
        }
    }
    
    private func fetchSessionStatus() async -> String? {
        do {
            let first = try await callSession()
            if first.result.needRefresh {
                let refreshed = await TokenManager.shared.refreshToken()
                if refreshed {
                    // 재발급 후 다시 세션 확인
                    do {
                        let second = try await callSession()
                        return normalizedStatus(from: second.result.status)
                    } catch {
                        // 세션 재확인 실패해도 토큰 갱신이 됐다면 홈으로 진입
                        return "HOME"
                    }
                } else {
                    // 재발급 실패 → 로그인 필요
                    return "LOGIN"
                }
            } else {
                // needRefresh가 아니더라도 서버 status를 홈 기준으로 정규화
                return normalizedStatus(from: first.result.status)
            }
        } catch {
            // 첫 세션이 401이면: refresh 시도 후 재호출
            if isUnauthorized(error) {
                let refreshed = await TokenManager.shared.refreshToken()
                if refreshed {
                    do {
                        let second = try await callSession()
                        return normalizedStatus(from: second.result.status)
                    } catch {
                        return "LOGIN"
                    }
                } else {
                    return "LOGIN"
                }
            }
            // 그 외 네트워크/서버 에러면 일단 로그인으로 진입(스플래시에서 막히지 않도록)
            return "LOGIN"
        }
    }
    
    private func callSession() async throws -> SessionResponseDTO {
        let res = try await container.useCaseProvider.authUseCase.request(.session)
        return try JSONDecoder().decode(SessionResponseDTO.self, from: res.data)
    }
    
    private func route(by status: String) {
        switch status {
        case "HOME":
            container.navigationRouter.hardReset(to: .VinnyTabView)
        case "ONBOARD":
            container.onboardingSelection.reset()
            container.navigationRouter.hardReset(to: .CategoryView)
        case "LOGIN":
            container.navigationRouter.hardReset(to: .LoginView)
        default:
            container.navigationRouter.hardReset(to: .LoginView)
        }
    }
    private func isUnauthorized(_ error: Error) -> Bool {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain { return false }
        // Moya/Alamofire에서 statusCode는 보통 NSError.code 또는 userInfo에 실립니다.
        // 여기선 간단히 서버가 401 계열이면 true로 간주
        if ns.code == 401 { return true }
        // 필요하면 더 정교하게 statusCode 추출
        return false
    }

    /// 서버 status를 홈 진입 기준으로 정규화
    private func normalizedStatus(from raw: String?) -> String {
        switch raw?.uppercased() {
        case "HOME":
            return "HOME"
        case "ONBOARD":
            return "ONBOARD"
        case "LOGIN", "AUTH", "LOGINED":
            return "LOGIN"
        default:
            // 알 수 없으면 로그인으로 유도
            return "LOGIN"
        }
    }
}

