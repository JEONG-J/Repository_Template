//
//  PostView.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import SwiftUI

struct ProfilePostView: View {
    @EnvironmentObject var viewModel: MypageViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        if viewModel.writtenPosts.isEmpty {
            EmptyView()
        } else {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.writtenPosts, id: \.postId) { post in
                    if let url = URL(string: post.imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
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
