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
                // 1) 토큰 재발급 시도
                guard await TokenManager.shared.refreshToken(),
                      let second = try? await callSession() else {
                    return "LOGIN"
                }
                // 2) 재발급 성공 & 세션 성공 → 홈 상태 반환
                return normalizedStatus(from: second.result.status)
            } else {
                return normalizedStatus(from: first.result.status)
            }
        } catch {
            // 첫 시도가 401 → 리프레시 → 다시 session → 성공해야 홈
            if isUnauthorized(error),
               await TokenManager.shared.refreshToken(),
               let second = try? await callSession() {
                return normalizedStatus(from: second.result.status)
            }
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
