//
//  CategoryView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedCategories: Set<String> = []
    let maxSelectionCount = 3
    let categories = [
        "🪖 밀리터리", "🇺🇸 아메카지", "🛹 스트릿", "🏔️ 아웃도어", "👕 캐주얼", "👖 데님", "💼 하이엔드", "🛠️ 워크웨어", "👞 레더", "🏃‍♂️ 스포티", "🐴 웨스턴", "👚 Y2K"
    ]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backRootRegular
                .ignoresSafeArea()
            VStack(spacing: 0) {
                //상단바
                ZStack {
                    HStack {
                        Button (action: {
                            container.navigationRouter.pop()                 }) {
                            Image("arrowBack")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                    }
                    Text("가입하기")
                        .font(.suit(.regular, size: 18))
                        .foregroundStyle(Color.contentBase)
                }
                .padding(16)
                                
                VStack(spacing: 2) {
                    Text("좋아하는 빈티지 취향을 3개까지 골라주세요!")
                        .font(.suit(.bold, size: 20))
                        .foregroundStyle(Color("ContentBase"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    Text("빈티지샵, 피드 추천 등 다양하게 맞춤형으로 활용됩니다.")
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color("ContentAdditive"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .padding(.bottom, 102.5)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        let isSelected = selectedCategories.contains(category)
                        Text(category)
                            .font(.suit(.regular, size: 16))
                            .foregroundStyle(isSelected ? Color("ContentAdditive") : Color("ContentDisabled"))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color("BorderOutlineStrong") : Color("BackFillRegular"), lineWidth: 2)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("BackFillRegular"))
                            )
                            .onTapGesture {
                                toggleSelection(for: category)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 112.5)
                Spacer().frame(height: 120) // 버튼 영역 확보!
            }

            LoginBottomView(
                title: "다음으로",
                isEnabled: !selectedCategories.isEmpty,
                action: {
                    container.navigationRouter.push(to: .BrandView)
                },
                assistiveText: "최소 한 개를 선택해야 다음으로 넘어갈 수 있어요"
            )
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(edges: .bottom)
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
    CategoryView(container: container)
        .environmentObject(container)
}

