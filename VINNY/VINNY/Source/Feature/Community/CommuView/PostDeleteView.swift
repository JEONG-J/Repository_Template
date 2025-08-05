//
//  PostDeleteView.swift
//  VINNY
//
//  Created by 홍지우 on 7/31/25.
//

import SwiftUI

struct PostDeleteView: View {
    @Binding var isShowing: Bool
    
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
        }
        .ignoresSafeArea(.all)
    }
}


