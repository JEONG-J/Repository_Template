//
//  VINNYApp.swift
//  VINNY
//
//  Created by 한태빈 on 6/25/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth


@main
struct VINNYApp: App {
    @StateObject var container: DIContainer = DIContainer()   // 상태 보존 위해 StateObject 권장

    init() {
        KakaoSDK.initSDK(appKey: "3c0f0d0b8ce9c68954e12724703a91f9")
    }
    
    var body: some Scene {
        WindowGroup {
            // 라우터의 path를 쓰는 NavigationStack
            NavigationStack(path: $container.navigationRouter.destinations) {
                //  앱 첫 화면: SplashView에서 /api/auth/session 호출 → 분기
                SplashView(container: container)
                    .environmentObject(container)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRoutingView(destination: destination)
                            .environmentObject(container)
                    }
            }
        }
    }
}
