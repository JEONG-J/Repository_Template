//
//  LocationView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI
import Foundation

struct LocationResetView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedCategories: Set<String> = []
    @State private var isSaving: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String? = nil
    let maxSelectionCount = 3
    let categories = [
        "홍대", "성수", "강남", "이태원", "동묘", "합정", "망원", "명동"
    ]
    // TODO: 실제 서버 regionId로 교체 필요
    private let regionNameToId: [String: Int] = [
        "홍대": 1, "성수": 2, "강남": 3, "이태원": 4,
        "동묘": 5, "합정": 6, "망원": 7, "명동": 8
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
                            submitResetRegion()
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
    
    private func submitResetRegion() {
        let selected = Array(selectedCategories)
        print("[ResetRegion] selectedCategories:", selected)

        let ids = selected.compactMap { regionNameToId[$0] }
        print("[ResetRegion] resolved ids:", ids)

        guard !ids.isEmpty else {
            errorMessage = "선택된 지역이 없어요."
            showErrorAlert = true
            return
        }

        isSaving = true
        Task {
            defer { isSaving = false }
            do {
                // 디버깅용으로 실제 바디 JSON 출력
                let debugBody = ResetRegionRequestDTO(regionIds: ids)
                if let data = try? JSONEncoder().encode(debugBody),
                   let json = String(data: data, encoding: .utf8) {
                    print("[ResetRegion] request body JSON:\n\(json)")
                }

                let resp = try await UsersAPITarget.resetRegion(ids: ids)
                print("[ResetRegion] response — isSuccess: \(resp.isSuccess), code: \(resp.code), message: \(resp.message)")
                container.navigationRouter.push(to: .VinnyTabView)
            } catch {
                print("[ResetRegion] error:", error)
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}
