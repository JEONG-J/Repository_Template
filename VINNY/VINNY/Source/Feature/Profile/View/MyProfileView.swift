//
//  MyprofileView.swift
//  VINNY
//
//  Created by 한태빈 on 7/4/25.
//

import SwiftUI

struct MyProfileView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedTab: Int = 0
    private let filters = ["게시물", "찜한 샵", "저장함"]

    var body: some View {
        VStack(spacing: 0) {
            // 상단 프로필 헤더
            TopsideProfileView(container: container)

            // 탭 필터
            ProfileSelectedFilter(
                selectedIndex: $selectedTab,
                filters: filters,
                counts: [5, 9, 1]
            )

            // 탭에 따른 콘텐츠 뷰
            Group {
                if selectedTab == 0 {
                    ProfilePostView()
                } else if selectedTab == 1 {
                    SavedShopView()
                } else {
                    SavedPostView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.backRootRegular)
        .navigationBarBackButtonHidden()
    }
}

