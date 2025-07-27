//
//  CommunityView.swift
//  VINNY
//
//  Created by 한태빈 on 7/4/25.
//

import SwiftUI

struct CommunityView: View {
    var body: some View {

        VStack(spacing: 0) {
            /// 상단 고정
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Text("커뮤니티")
                        .font(.suit(.bold, size: 24))
                        .foregroundStyle(Color.contentBase)
                    
                    Spacer()
                    
                    Image("plus")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                HStack(spacing: 8) {
                    Image("magnifier")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("빈티지샵, 게시글 검색하기")
                        .font(.suit(.regular, size: 16))
                        .foregroundStyle(Color.contentAssistive)
                    
                    Spacer()
                    
                    Image("close")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.backFillRegular)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            /// 스크롤뷰
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { post in
                        PostCardView()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)

                    }
                    
                    Spacer()
                        .frame(height: 56)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        }
        .background(Color.backFillStatic)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CommunityView()
}
