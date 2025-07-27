//
//  ReviewsView.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI

struct ReviewsView: View {
    private var userName: String = "유저 이름"
    private var userInfo: String = "유저 소개 글"
    private var timestamp: String = "1시간 전"
    private var title: String = "제목"
    private var content: String = "글 내용"
    
    var body: some View {
        VStack {
            ReviewsCard(Name: userName, Info: userInfo, Timestamp: timestamp, Title: title, Content: content)
        }
    }
    
    private func ReviewsCard(Name: String, Info: String, Timestamp: String, Title: String, Content: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image("emptyImage")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Name)")
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color.contentBase)
                    Text("\(Info)")
                        .font(.suit(.regular, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            VStack (alignment: .leading, spacing: 2) {
                Text("\(Timestamp)")
                    .font(.suit(.regular, size: 12))
                    .foregroundStyle(Color.contentAssistive)
                Text("\(Title)")
                    .font(.suit(.regular, size: 18))
                    .foregroundStyle(Color.contentBase)
                Text("\(Content)")
                    .font(.suit(.regular, size: 14))
                    .foregroundStyle(Color.contentAdditive)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            HStack(spacing: 12) {
                Image("emptyBigImage")
                    .resizable()
                    .aspectRatio(1.6, contentMode: .fill)
                    .frame(width: (UIScreen.main.bounds.width - 12 - 32) / 2, height: 104 )
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                Image("emptyBigImage")
                    .resizable()
                    .aspectRatio(1.6, contentMode: .fill)
                    .frame(width: (UIScreen.main.bounds.width - 12 - 32) / 2, height: 104 )
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
        }
    }
}

#Preview {
    ReviewsView()
}
