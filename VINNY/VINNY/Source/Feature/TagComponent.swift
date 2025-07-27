//
//  TagComponent.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

func TagComponent(tag: String) -> some View {
    Text("\(tag)")
        .font(.suit(.medium, size: 12))
        .foregroundStyle(Color.contentAdditive)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.backFillRegular)
        )
}

func SelectingTagComponent(tag: String, selectedTag: Bool, onTap: @escaping () -> Void) -> some View {
    Button(action: onTap) {
        Text(tag)
            .font(.suit(.medium, size: 12))
            .foregroundStyle(selectedTag ? Color.contentInverted : Color.contentAdditive)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(selectedTag ? Color.backFillInverted : Color.backFillRegular)
            )
    }
    .buttonStyle(.plain) // 버튼 기본 애니메이션 제거
}
