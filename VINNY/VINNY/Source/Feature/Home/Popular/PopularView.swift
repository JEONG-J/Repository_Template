//
//  PopularView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct PopularView: View {
    @EnvironmentObject var container: DIContainer
        
    init(container: DIContainer) {
        
    }
    
    @State private var posts: [PostItemDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var page: Int = 0
    @State private var size: Int = 10
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("인기 게시글")
                    .font(.suit(.bold, size: 20))
                    .foregroundStyle(Color.contentBase)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
            }
            .padding(.top, 4)
            
            if isLoading {
                ProgressView()
                    .padding(.vertical, 24)
            } else if let err = errorMessage {
                Text(err)
                    .foregroundStyle(.red)
                    .padding(.vertical, 24)
            } else {
                ForEach(posts, id: \.self) { item in
                    PostCardView(item: item)
                        .environmentObject(container)
                        .padding(.vertical, 10)
                }
            }
        }
        .onAppear {
            Task {
                await fetchPopular(reset: true)
            }
        }
        .task { await fetchPopular(reset: true) }
        .refreshable { await fetchPopular(reset: true) }
    }
    
    // MARK: - Networking
    @MainActor
    private func fetchPopular(reset: Bool) async {
        if reset { page = 0 }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let result: PostListResultDTO = try await PostAPITarget.getPosts(page: page, size: size)
            if reset {
                posts = result.posts
            } else {
                posts += result.posts
            }
            // 필요 시 무한스크롤 대비
            // page += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    let container = DIContainer()
    PopularView(container: container)
        .environmentObject(container)
}
