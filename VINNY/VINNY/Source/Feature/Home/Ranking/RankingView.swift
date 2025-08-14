//
//  RankingView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var container: DIContainer
    
    init(container: DIContainer) {
        
    }
    private var categories: [String] = ["#빈티지", "#스트릿", "#레더"]
    private var styles: [String] = [
        "모든 종류", "🪖 밀리터리", "🇺🇸 아메카지", "🛹 스트릿", "🏔️ 아웃도어", "👕 캐주얼", "👖 데님", "💼 하이엔드", "🛠️ 워크웨어", "👞 레더", "‍🏃‍♂️ 스포티", "🐴 웨스턴", "👚 Y2K"
    ]
    private var regions: [String] = [
        "모든 지역", "홍대", "성수", "강남", "이태원", "동묘", "합정"
    ]
    @State private var selectedStyles: Set<String> = ["모든 종류"]
    @State private var selectedRegions: Set<String> = ["모든 지역"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Spacer().frame(height: 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(styles, id: \.self) { style in
                            SelectingTagComponent(
                                tag: style,
                                selectedTag: selectedStyles.contains(style),
                                onTap: {
                                    if style == "모든 종류" {
                                        selectedStyles = ["모든 종류"]
                                    } else {
                                        if selectedStyles.contains(style) {
                                            selectedStyles.remove(style)
                                        } else {
                                            if selectedStyles.contains("모든 종류") {
                                                selectedStyles.remove("모든 종류")
                                            }
                                            selectedStyles.insert(style)
                                        }
                                    }
                                }
                            )
                    }
                }
                .padding(.vertical, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(regions, id: \.self) { region in
                            SelectingTagComponent(
                                tag: region,
                                selectedTag: selectedRegions.contains(region),
                                onTap: {
                                    if region == "모든 지역" {
                                        selectedRegions = ["모든 지역"]
                                    } else {
                                        if selectedRegions.contains(region) {
                                            selectedRegions.remove(region)
                                        } else {
                                            if selectedRegions.contains("모든 지역") {
                                                selectedRegions.remove("모든 지역")
                                            }
                                            selectedRegions.insert(region)
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                
                HStack {
                    Text("빈티지샵 추천")
                        .font(.suit(.bold, size: 20))
                        .foregroundStyle(Color.contentBase)
                    
                    Spacer()
                    
                    Text("59분 전")
                        .font(.suit(.light, size: 14))
                        .foregroundStyle(Color.contentAdditive)
                }
                .padding(.top, 10)
                .padding(.bottom, 6)
                .padding(.horizontal, 6)
            }
            
            ForEach(1..<11, id: \.self) { rank in
                rankingCard(rank: rank)
            }
        }
    }
    
    private func rankingCard(rank: Int) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("\(rank)")
                    .font(.suit(.bold, size: 14))
                    .foregroundStyle(Color.contentAdditive)
                    .frame(width: 20)
                Image("emptyImage")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("샵 이름")
                        .font(.suit(.medium, size: 18))
                        .foregroundStyle(Color.contentBase)
                    Text("샵 주소")
                        .font(.suit(.light, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                Spacer()
                
                Button(action: {
                    container.navigationRouter.push(to: .ShopView(id: 0)) // TODO: 실제 shopId로 교체
                }) {
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.vertical, 10)
            
            /// tags
            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image("mapPin")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("지역") 
                        .font(.suit(.medium, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.backFillRegular)
                )
                
                ForEach(categories, id: \.self) { category in
                    TagComponent(tag: category)
                }
            }
            .padding(.vertical, 8)
            
            Image("emptyBigImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 104)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.vertical, 8)
            
            Divider().padding(.vertical, 10)
        }
    }
}

#Preview {
    let container = DIContainer()
    RankingView(container: container)
        .environmentObject(container)
}
