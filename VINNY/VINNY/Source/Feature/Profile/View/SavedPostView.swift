//
//  SavedPostView.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import SwiftUI
import Kingfisher

struct SavedPostView: View {
    @EnvironmentObject var viewModel: MypageViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        if viewModel.savedPosts.isEmpty {
            EmptyView()
        } else {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.savedPosts, id: \.postId) { post in
                    if let url = URL(string: post.imageUrl) {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: (UIScreen.main.bounds.width - 40) / 3,
                                   height: (UIScreen.main.bounds.width - 40) / 3)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
