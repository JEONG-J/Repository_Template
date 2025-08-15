//
//  PostDeleteView.swift
//  VINNY
//
//  Created by 홍지우 on 7/31/25.
//

import SwiftUI

struct PostDeleteView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var container: DIContainer
    @State private var isDeleting: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.24))
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("정말 게시글을 삭제하시겠습니까?")
                        .font(.suit(.bold, size: 18))
                        .foregroundStyle(Color.contentBase)
                    
                    Text("게시글 삭제 시 영구적으로 삭제되며 \n복원이 불가합니다")
                        .font(.suit(.light, size: 14))
                        .foregroundStyle(Color.contentAdditive)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                
                HStack(spacing: 8) {
                    Button(action: {
                        Task { @MainActor in
                            guard !isDeleting else { return }
                            guard let targetId = container.editingPostId else {
                                errorMessage = "삭제할 게시글 ID가 없습니다."
                                return
                            }
                            isDeleting = true
                            defer { isDeleting = false }
                            do {
                                _ = try await PostAPITarget.performDelete(postId: targetId)
                                print("[PostDelete] success — id: \(targetId)")
                                showSuccessAlert = true
                            } catch {
                                print("[PostDelete] failed: \(error)")
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("삭제")
                            .font(.suit(.medium, size: 14))
                            .foregroundStyle(Color.contentElevated)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.semanticDangerStrong)
                    )
                    
                    Button(action: {
                        isShowing = false
                    }) {
                        Text("취소")
                            .font(.suit(.medium, size: 14))
                            .foregroundStyle(Color.contentBase)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.backFillRegular)
                    )
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
            .background(Color.backFillStatic)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            
            if isDeleting {
                ProgressView().controlSize(.large)
            }
        }
        .ignoresSafeArea(.all)
        .alert("삭제 완료", isPresented: $showSuccessAlert) {
            Button("확인") {
                // 다이얼로그 닫고 바로 목록으로 복귀
                isShowing = false
                container.navigationRouter.pop()
            }
        } message: {
            Text("게시글이 삭제되었습니다.")
        }
        .alert("삭제 완료", isPresented: $showSuccessAlert) {
            Button("확인") {
                // 다이얼로그 닫기 → 상위(PostView)의 onChange 또는 라우터에서 pop 처리
                isShowing = false
            }
        } message: {
            Text("게시글이 삭제되었습니다.")
        }
    }
}
