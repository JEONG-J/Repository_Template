//
//  CommunityResultCell.swift
//  VINNY
//
//  Created by 소민준 on 8/5/25.
//
import SwiftUI
import Foundation

    // 커뮤니티 결과 셀: 유저 정보를 표시하는 셀
    struct CommunityResultCell: View {
        let user: UserResult

        var body: some View {
            HStack(spacing: 12) {
                // 프로필 이미지 (placeholder 사용 또는 user.imageURL 적용)
                Image("example_profile") // 실제 사용 시에는 user.profileImageName 또는 AsyncImage 등으로 교체
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                // 이름 및 포지션
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.suit(.semibold, size: 16))
                        .foregroundColor(.white)

                    Text(user.position)
                        .font(.suit(.regular, size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                // 오른쪽 화살표
                Image(systemName: "chevron.right")
                    .foregroundColor(.contentAssistive)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.backRootRegular)
        }
    }
    
