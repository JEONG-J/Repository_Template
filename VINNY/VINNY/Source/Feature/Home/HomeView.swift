//
//  HomeView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer) {
            
        }
    @State var selectedFilter: Int = 0
    let filters: [String] = ["추천", "랭킹", "인기"]
    let isNewRecommend: Bool = true


    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 상단 고정
            VStack(spacing: 0) {
                /// 로고 및 알림
                HStack(spacing: 16) {
                    Image("vinnylogo")
                        .resizable()
                        .frame(width: 50.4, height: 28)
                    
                    Spacer()
                    
                    Button(action: {
                        container.navigationRouter.push(to: .NotificationView)
                    }) {
                        Image("notifications")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                /// 검색창 이동
                Button(action: {
                    container.navigationRouter.push(to: .SearchView)
                }) {
                    HStack(spacing: 8) {
                        Image("magnifier")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("빈티지샵, 게시글 검색하기")
                            .font(.suit(.regular, size: 16))
                            .foregroundStyle(Color.contentAssistive)
                        
                        Spacer()
                        
                        Image("close")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color.backFillRegular)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            // MARK: - TabView, 스크롤뷰
            HomeTabView
        }
        .navigationBarBackButtonHidden()
        .background(Color.backFillStatic)
    }
    
    // MARK: - CustomTabView
    private var HomeTabView: some View {
        return VStack(spacing: 0) {
            GeometryReader { geometry in
                let tabSize = (geometry.size.width / 2) / CGFloat(filters.count)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(filters.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    selectedFilter = index
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text(filters[index])
                                        .font(selectedFilter == index ? .suit(.bold, size: 16) : .suit(.light, size: 16))
                                        .foregroundStyle(selectedFilter == index ? Color.contentBase : Color.contentDisabled)
                                        .frame(width: tabSize)
                                        .multilineTextAlignment(.center)
                                        .overlay(
                                            Group {
                                                if filters[index] == "추천", isNewRecommend {
                                                    Circle()
                                                        .frame(width: 6, height: 6)
                                                        .foregroundStyle(Color.backFillInverted)
                                                        .offset(x: 24, y: 0)
                                                }
                                            }
                                        )
                                }
                                .frame(width: tabSize)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)

                    //밑줄
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.borderDividerRegular)
                            .frame(height: 1)

                        Rectangle()
                            .fill(Color.contentBase)
                            .frame(width: tabSize, height: 2)
                            .offset(x: CGFloat(selectedFilter) * tabSize, y: -1)
                            .animation(.easeInOut(duration: 0.25), value: selectedFilter)
                            .padding(.horizontal, 8)
                    }
                }
            }
            .frame(height: 55)


            if selectedFilter == 0 {
                RecommendView(container: container)
                    .padding(.horizontal, 16)
            } else if selectedFilter == 1{
                RankingView(container: container)
                    .padding(.horizontal, 16)
            } else {
                PopularView(container: container)
                    .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    let container = DIContainer()
    HomeView(container: container)
        .environmentObject(container)
}
