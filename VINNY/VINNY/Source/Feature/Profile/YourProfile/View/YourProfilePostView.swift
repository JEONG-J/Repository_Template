//
//  YourProfilePostView.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import SwiftUI
import Kingfisher

struct YourProfilePostView: View {
    @EnvironmentObject var viewModel: YourpageViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        if viewModel.posts.isEmpty {
            EmptyView()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.posts, id: \.postId) { post in
                        if let url = URL(string: post.imageUrl) {
                            KFImage(url)
                                .placeholder {
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(.gray.opacity(0.2))
                                        ProgressView()
                                    }
                                }
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .clipped()
                        }
                    }
                }
                .padding(.top, 1)
            }
        }
    }
}
