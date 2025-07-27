//
//  SavedPostView.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import SwiftUI

struct SavedPostView: View {
    let items = Array(repeating: Color.gray.opacity(0.2), count: 1)
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

#Preview {
    SavedPostView()
}
