//
//  PhotosView.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI

let columns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]

struct PhotosView: View {
    @StateObject private var viewModel: PhotosViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: PhotosViewModel(mock: true))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.posts, id: \.id) { post in
                    VStack {
                        AsyncImage(url: URL(string: post.imageUrl.first ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(1.6, contentMode: .fill)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(1.6, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .task {
                        if post.id == viewModel.posts.last?.id {
                            viewModel.fetchPosts()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}

#Preview {
    PhotosView()
}
