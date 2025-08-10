//
//  BrandView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//


import SwiftUI

struct BrandView: View {
    @EnvironmentObject var container: DIContainer
    private let options = OnboardingCatalog.brands   // [OnboardOption]
    private let maxSelectionCount = OnboardingSelection.Limit.brandMax
    init(container: DIContainer) {
        
    }

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
                        ForEach(options) { opt in
                            let isSelected = container.onboardingSelection.brandIds.contains(opt.id)
                            VStack(spacing: 8) {
                                Image(opt.title)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(isSelected ? Color("SemanticBrandStrong") : .clear, lineWidth: 2)
                                    )

                                Text(opt.title)
                                    .font(.suit(.regular, size: 14))
                                    .foregroundStyle(isSelected ? Color("ContentAdditive") : Color("ContentDisabled"))
                            }
                            .frame(maxWidth: .infinity)
                            .onTapGesture { toggle(opt.id) }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                Spacer()
                    .frame(height: !container.onboardingSelection.brandIds.isEmpty ? 100 : 130)
                    .animation(.easeInOut, value: !container.onboardingSelection.brandIds.isEmpty)
            }

            // 하단 버튼 고정
            LoginBottomView(
                title: "다음으로",
                isEnabled: !container.onboardingSelection.brandIds.isEmpty,
                action: {
                    let count = container.onboardingSelection.brandIds.count
                    guard count >= OnboardingSelection.Limit.brandMin else { return }
                    container.navigationRouter.push(to: .ClothTypeView)
                },
                assistiveText: "최소 한 개를 선택해야 다음으로 넘어갈 수 있어요"
            )
        }
        .navigationBarBackButtonHidden()
    }

    private func toggle(_ id: Int) {
        var set = container.onboardingSelection.brandIds
        if set.contains(id) {
            set.remove(id)
        } else if set.count < maxSelectionCount {
            set.insert(id)
        }
        container.onboardingSelection.brandIds = set
    }
}


 
