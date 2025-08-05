//
//  BrandView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//


import SwiftUI

struct BrandResetView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedCategories: Set<String> = []
    let maxSelectionCount = 5
    let categories = [
        "리바이스", "나이키", "노스페이스", "디젤", "디키즈", "라코스테", "랭글러", "마르지엘라",
        "버버리", "베이프", "슈프림", "스투시", "칼하트", "폴로", "아디다스", "파타고니아", "아비렉스"
    ]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backRootRegular
                .ignoresSafeArea()
            VStack(spacing: 0) {
                // 상단 설명
                VStack(spacing: 2) {
                    Text("좋아하는 브랜드를 최대 5개 골라주세요.")
                        .font(.suit(.bold, size: 20))
                        .foregroundStyle(Color("ContentBase"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("빈티지샵 추천 등 취향을 위해 맞춤형으로 활용됩니다.")
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color("ContentAdditive"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 59)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // 스크롤 가능한 브랜드 목록
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categories, id: \.self) { category in
                            let isSelected = selectedCategories.contains(category)
                            VStack(spacing: 8) {
                                Image(category)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(isSelected ? Color("SemanticBrandStrong") : .clear, lineWidth: 2)
                                    )

                                Text(category)
                                    .font(.suit(.regular, size: 14))
                                    .foregroundStyle(isSelected ? Color("ContentAdditive") : Color("ContentDisabled"))
                            }
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                toggleSelection(for: category)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .frame(height: 473)
                
                ResetBottomView(
                    title: "저장하기",
                    isEnabled: !selectedCategories.isEmpty,
                    action: {
                        container.navigationRouter.push(to: .VinnyTabView)
                    }
                )
                .frame(height: 76)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func toggleSelection(for category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else if selectedCategories.count < maxSelectionCount {
            selectedCategories.insert(category)
        }
    }
}


#Preview {
    let container = DIContainer()
    BrandResetView(container: container)
        .environmentObject(container)
}
