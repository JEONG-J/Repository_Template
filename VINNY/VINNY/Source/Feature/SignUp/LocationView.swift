//
//  LocationView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct LocationView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedCategories: Set<String> = []
    let maxSelectionCount = 3
    let categories = [
        "홍대", "성수", "강남", "이태원", "동묘", "합정", "망원", "명동"
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
                    
                    Divider()
                    
                    VStack(spacing: 2) {
                        Text("마지막이에요! 관심 지역을 선택해주세요")
                            .font(.suit(.bold, size: 20))
                            .foregroundStyle(Color("ContentBase"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        Text("최대 3개까지 선택할 수 있어요.")
                            .font(.suit(.medium, size: 16))
                            .foregroundStyle(Color("ContentAdditive"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                    .padding(.bottom, 154.5)

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
                    .padding(.bottom, 164.5)

                    Spacer().frame(height: 120) // 버튼 영역 확보!
                }

                LoginBottomView(
                    title: selectedCategories.isEmpty ? "다음으로" : "완료하기",
                    isEnabled: !selectedCategories.isEmpty,
                    action: {
                        container.navigationRouter.push(to: .VinnyTabView)
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
    LocationView(container: container)
        .environmentObject(container)
}
