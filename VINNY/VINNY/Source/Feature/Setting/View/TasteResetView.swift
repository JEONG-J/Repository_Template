//
//  TasteResetView.swift
//  VINNY
//
//  Created by 한태빈 on 7/31/25.
//
import SwiftUI

struct TasteResetView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedTab: Int = 0
    private let filters = ["스타일", "브랜드", "제품군","지역"]

    var body: some View {
        VStack(spacing: 0) {
            //상단바
            ZStack {
                HStack {
                    Button (action: {
                        container.navigationRouter.pop()                 }) {
                        Image("arrowBack")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 16)

                    }
                    Spacer()
                }
                Text("취향 재설정")
                    .font(.suit(.regular, size: 18))
                    .foregroundStyle(Color.contentBase)
            }
            .frame(height: 60)
            
            // 탭 필터
            TasteSelectionTab(
                selectedIndex: $selectedTab,
                titles: filters
            )

            // 탭에 따른 콘텐츠 뷰
            Group {
                if selectedTab == 0 {
                    CategoryResetView(container: container)
                } else if selectedTab == 1 {
                    BrandResetView(container: container)
                } else if selectedTab == 2 {
                    ClothTypeResetView(container: container)
                } else {
                    LocationResetView(container: container)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.backRootRegular)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    let container = DIContainer()
    TasteResetView(container: container)
        .environmentObject(container)
}
