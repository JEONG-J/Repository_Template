//
//  CategoryView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct CategoryView: View {
    let container: DIContainer
    init(container: DIContainer) {
        self.container = container
    }
    private let options = OnboardingCatalog.styles   // [OnboardOption]
    private let maxSelectionCount = OnboardingSelection.Limit.styleMax

    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
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
                                .padding(.leading, 16)
                        }
                        Spacer()
                    }
                    Text("가입하기")
                        .font(.suit(.regular, size: 18))
                        .foregroundStyle(Color.contentBase)
                }
                .frame(height: 60)
                                
                VStack(spacing: 2) {
                    Text("좋아하는 빈티지 취향을 3개까지 골라주세요!")
                        .font(.suit(.bold, size: 20))
                        .foregroundStyle(Color("ContentBase"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("빈티지샵, 피드 추천 등 다양하게 맞춤형으로 활용됩니다.")
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color("ContentAdditive"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 59)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(options) { opt in
                        let isSelected = container.onboardingSelection.vintageStyleIds.contains(opt.id)
                        Text(opt.title)
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
                            .onTapGesture { toggle(opt.id) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 102.5)

                LoginBottomView(
                    title: "다음으로",
                    isEnabled: !container.onboardingSelection.vintageStyleIds.isEmpty,
                    action: {
                        let count = container.onboardingSelection.vintageStyleIds.count
                        guard count >= OnboardingSelection.Limit.styleMin else { return }
                        container.navigationRouter.push(to: .BrandView)
                    },
                    assistiveText: "최소 한 개를 선택해야 다음으로 넘어갈 수 있어요"
                )
                .frame(height: 104)
            }
            
        }
        .navigationBarBackButtonHidden()
    }

    private func toggle(_ id: Int) {
        var set = container.onboardingSelection.vintageStyleIds
        if set.contains(id) {
            set.remove(id)
        } else if set.count < maxSelectionCount {
            set.insert(id)
        }
        container.onboardingSelection.vintageStyleIds = set
    }
}

#Preview {
    let container = DIContainer()
    CategoryView(container: container)
}

