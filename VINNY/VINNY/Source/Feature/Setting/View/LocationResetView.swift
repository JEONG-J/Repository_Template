//
//  LocationView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct LocationResetView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedCategories: Set<String> = []
    let maxSelectionCount = 3
    let categories = [
        "홍대", "성수", "강남", "이태원", "동묘", "합정", "망원", "명동"
    ]
    
    let columns = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]

        var body: some View {
            ZStack(alignment: .bottom) {
                Color.backRootRegular
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    
                    VStack(spacing: 2) {
                        Text("마지막이에요! 관심 지역을 선택해주세요")
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
                    .padding(.vertical, 136.5)
                    
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
    LocationView(container: container)
        .environmentObject(container)
}
