//
//  PhotosViewModel.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

struct Photos: Identifiable {
    let id: UUID
    let imageUrl: [String]
}

import Foundation
import Combine

final class PhotosViewModel: ObservableObject {
    @Published var posts: [Photos] = []
    
    private var isLoading = false
    private var page = 1
    private let pageSize = 12
    
    init(mock: Bool = false) {
        if mock {
            loadMockData()
        } else {
            fetchPosts()
        }
    }
    
    func fetchPosts() {
        guard !isLoading else { return }
        isLoading = true
        
        // 실 서버 요청 대신 딜레이와 함께 mock 추가
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newPosts = (0..<self.pageSize).map { _ in
                Photos(id: UUID(), imageUrl: ["https://via.placeholder.com/300"])
            }
            self.posts.append(contentsOf: newPosts)
            self.page += 1
            self.isLoading = false
        }
    }
    
    private func loadMockData() {
        self.posts = (0..<15).map { _ in
            Photos(id: UUID(), imageUrl: ["https://via.placeholder.com/300"])
        }
    }
}
