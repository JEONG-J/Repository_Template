//
//  CategoryView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct CategoryResetView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedCategories: Set<String> = []
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false

    
    private let styleNameToId: [String: Int] = [
        "🪖 밀리터리": 1,
        "🇺🇸 아메카지": 2,
        "🛹 스트릿": 3,
        "🏔️ 아웃도어": 4,
        "👕 캐주얼": 5,
        "👖 데님": 6,
        "💼 하이엔드": 7,
        "🛠️ 워크웨어": 8,
        "👞 레더": 9,
        "🏃‍♂️ 스포티": 10,
        "🐴 웨스턴": 11,
        "👚 Y2K": 12
    ]
    let maxSelectionCount = 3
    let categories = [
        "🪖 밀리터리", "🇺🇸 아메카지", "🛹 스트릿", "🏔️ 아웃도어", "👕 캐주얼", "👖 데님", "💼 하이엔드", "🛠️ 워크웨어", "👞 레더", "🏃‍♂️ 스포티", "🐴 웨스턴", "👚 Y2K"
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
                .padding(.vertical, 84.5)
                
                ResetBottomView(
                    title: "저장하기",
                    isEnabled: !selectedCategories.isEmpty,
                    action: {
                        save()
                    }
                )
                .frame(height: 76)
            }
        }
        .navigationBarBackButtonHidden()
        .overlay(alignment: .center) {
            if isSaving { ProgressView().controlSize(.large) }
        }
        .alert("저장 실패", isPresented: $showErrorAlert) {
            Button("확인") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "알 수 없는 오류")
        }
    }

    private func toggleSelection(for category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else if selectedCategories.count < maxSelectionCount {
            selectedCategories.insert(category)
        }
    }
    
    private func save() {
        // 선택된 카테고리명을 서버 ID로 매핑 (0은 무시)
        let ids = selectedCategories.compactMap { styleNameToId[$0] }.filter { $0 > 0 }
        guard !ids.isEmpty else {
            errorMessage = "선택한 취향의 ID 매핑이 없습니다. styleNameToId를 채워주세요."
            showErrorAlert = true
            return
        }

        isSaving = true
        Task {
            do {
                let res = try await UsersAPITarget.resetVintageStyle(ids: ids)
                await MainActor.run {
                    isSaving = false
                    if res.isSuccess {
                        container.navigationRouter.push(to: .VinnyTabView)
                    } else {
                        errorMessage = res.message
                        showErrorAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    let container = DIContainer()
    CategoryResetView(container: container)
        .environmentObject(container)
}

