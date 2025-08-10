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
                    let second = try await callSession()
                    return second.result.status
                } else {
                    return "LOGIN"
                }
            } else {
                return first.result.status
            }
        } catch {
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
            container.navigationRouter.destinations = [.VinnyTabView]
        case "ONBOARD":
            container.onboardingSelection.reset()
            container.navigationRouter.destinations = [.CategoryView]
        default:
            container.navigationRouter.destinations = [.LoginView]
        }
    }
}
