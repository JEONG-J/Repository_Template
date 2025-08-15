// SearchResultViewModel.swift
import SwiftUI
import Foundation

final class SearchResultViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var shops: [Shops] = [] {
        didSet { print("vm.shops updated:", shops.count) }
    }
    @Published var posts: [PostSearchResultDTO] = [] {
        didSet { print("vm.posts updated:", posts.count) }
    }
    @Published var error: String? {
        didSet { if let e = error { print("vm.error:", e) } }
    }

    // 동시에 여러 검색이 겹칠 때 이전 작업 취소
    private var currentTask: Task<Void, Never>?

    @MainActor
    func bootstrap(keyword: String, tab: Int) async {
        await search(keyword: keyword, tab: tab)
    }

    @MainActor
    func search(keyword: String, tab: Int) async {
        let kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !kw.isEmpty else { return }

        // 이전 검색 취소
        currentTask?.cancel()

        isLoading = true
        error = nil

        // 탭에 맞춰 반대쪽 리스트 비워서 stale 데이터 노출 방지
        if tab == 0 { posts = [] } else { shops = [] }

        currentTask = Task { [weak self] in
            guard let self else { return }
            do {
                if tab == 0 {
                    let data = try await SearchAPITarget.searchShops(keyword: kw)
                    // Task가 취소된 뒤엔 반영하지 않기
                    try Task.checkCancellation()
                    await MainActor.run {
                        self.shops = data
                        self.isLoading = false
                    }
                } else {
                    let data = try await SearchAPITarget.searchPosts(keyword: kw)
                    try Task.checkCancellation()
                    await MainActor.run {
                        self.posts = data
                        self.isLoading = false
                    }
                }
            } catch is CancellationError {
                // 취소는 조용히 무시
                await MainActor.run { self.isLoading = false }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
