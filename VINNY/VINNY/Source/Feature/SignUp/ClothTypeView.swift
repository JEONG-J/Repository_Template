//
//  ClothView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct ClothTypeView: View {
    @EnvironmentObject var container: DIContainer

    private let options = OnboardingCatalog.items   // [OnboardOption]
    private let maxSelectionCount = OnboardingSelection.Limit.itemMax
    init(container: DIContainer) {
        // 라우팅 시그니처 맞추기용 (실제 사용은 @EnvironmentObject)
    }
    
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
                    Text("어떤 옷을 주로 찾으시나요?")
                        .font(.suit(.bold, size: 20))
                        .foregroundStyle(Color("ContentBase"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("최대 3개까지 선택할 수 있어요.")
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color("ContentAdditive"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 59)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(options) { opt in
                        let isSelected = container.onboardingSelection.vintageItemIds.contains(opt.id)
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
                .padding(.vertical, 154.5)
                
                LoginBottomView(
                    title: "다음으로",
                    isEnabled: !container.onboardingSelection.vintageItemIds.isEmpty,
                    action: {
                        let count = container.onboardingSelection.vintageItemIds.count
                        guard count >= OnboardingSelection.Limit.itemMin else { return }
                        container.navigationRouter.push(to: .LocationView)
                    },
                    assistiveText: "최소 한 개를 선택해야 다음으로 넘어갈 수 있어요"
                )
                .frame(height: 104)

            }

        }
        .navigationBarBackButtonHidden()
    }

    private func toggle(_ id: Int) {
        var set = container.onboardingSelection.vintageItemIds
        if set.contains(id) {
            set.remove(id)
        } else if set.count < maxSelectionCount {
            set.insert(id)
        }
        container.onboardingSelection.vintageItemIds = set
    }
}

