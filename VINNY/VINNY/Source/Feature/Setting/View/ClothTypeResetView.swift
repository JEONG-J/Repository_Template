//
//  ClothView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct ClothTypeResetView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var selectedCategories: Set<String> = []
    @State private var isSaving: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String? = nil
    let maxSelectionCount = 3
    let categories = [
        "아우터", "상의", "하의", "신발", "모자", "악세서리", "잡화", "기타"
    ]
    
    /// TODO: ✅ 백엔드 실제 ID로 맞춰주세요. (임시 매핑)
    private let itemNameToId: [String: Int] = [
        "아우터": 1,
        "상의": 2,
        "하의": 3,
        "신발": 4,
        "모자": 5,
        "악세서리": 6,
        "잡화": 7,
        "기타": 8
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
                        submitResetVintageItem()
                    }
                )
                .frame(height: 76)

            }
        }
        .navigationBarBackButtonHidden()
        .overlay(alignment: .center) {
            if isSaving {
                ProgressView().controlSize(.large)
            }
        }
        .alert("저장 실패", isPresented: $showErrorAlert) {
            Button("확인") { showErrorAlert = false }
        } message: {
            Text(errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
    }

    private func toggleSelection(for category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else if selectedCategories.count < maxSelectionCount {
            selectedCategories.insert(category)
        }
    }
}

private extension ClothTypeResetView {
    /// 선택한 카테고리를 VintageItem ID 배열로 변환해 서버에 전송
    func submitResetVintageItem() {
        // 디버깅: 사용자가 선택한 이름들
        print("[ResetItem] selectedCategories:", Array(selectedCategories))
        
        // 이름 → ID 매핑
        let ids: [Int] = selectedCategories.compactMap { itemNameToId[$0] }
        
        // 디버깅: 변환된 ID 배열과 실제 전송 바디를 JSON으로 출력
        let bodyDict: [String: Any] = ["vintageItemIds": ids]
        if let data = try? JSONSerialization.data(withJSONObject: bodyDict, options: [.prettyPrinted]),
           let jsonStr = String(data: data, encoding: .utf8) {
            print("[ResetItem] request body JSON:\n\(jsonStr)")
        } else {
            print("[ResetItem] (warn) failed to serialize request body for log")
        }
        
        // 유효성 검사
        guard !ids.isEmpty else {
            errorMessage = "선택한 항목의 ID 매핑을 찾을 수 없습니다.\n관리자에게 문의해주세요."
            showErrorAlert = true
            return
        }
        
        isSaving = true
        Task { @MainActor in
            do {
                let res = try await UsersAPITarget.resetVintageItem(ids: ids)
                // 디버깅: 서버 응답 로그
                print("[ResetItem] response — isSuccess: \(res.isSuccess), code: \(res.code), message: \(res.message)")
                
                if res.isSuccess {
                    // 성공 시 홈으로 이동하거나 원하는 화면으로 이동
                    container.navigationRouter.push(to: .VinnyTabView)
                } else {
                    errorMessage = res.message
                    showErrorAlert = true
                }
            } catch {
                print("[ResetItem] API error:", error)
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
            isSaving = false
        }
    }
}
