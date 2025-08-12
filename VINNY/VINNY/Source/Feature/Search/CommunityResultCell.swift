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
        let items = Array(repeating: Color.gray.opacity(0.2), count: 5) // 예시: 게시물 30개

        let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)

        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(items.indices, id: \.self) { index in
                        Button {
                            // 클릭 시 동작 (예: 상세 보기)
                        } label: {
                            Rectangle()
                                .foregroundStyle(items[index])
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            .padding(.top, 1)
        }
    }
