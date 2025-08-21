import Foundation
import SwiftUI

/// 타인 프로필 화면용 ViewModel
/// - Handles: 사용자 프로필 조회, 게시글 조회, 찜한 샵 조회
/// - Threading: async/await 기반 상태 업데이트
final class YourpageViewModel: ObservableObject {
    // MARK: - Dependencies
    private let useCase: DefaultNetworkManager<UsersAPITarget>

    // MARK: - 상태
    @Published var profile: yourProfileResponse?
    @Published var posts: [YourPost] = []
    @Published var savedShops: [YourSavedShop] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init(useCase: DefaultNetworkManager<UsersAPITarget>) {
        self.useCase = useCase
    }

    // MARK: - API 호출

    func fetchAll(userId: Int) async {
        isLoading = true
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchProfile(userId: userId) }
            group.addTask { await self.fetchPosts(userId: userId) }
            group.addTask { await self.fetchSavedShops(userId: userId) }
        }
        isLoading = false
    }

    @MainActor
    func fetchProfile(userId: Int) async {
        print("[OtherProfile] fetchProfile 호출됨")
        await withCheckedContinuation { continuation in
            useCase.requestUnwrap(
                target: .getYourProfile(userId: userId),
                envelope: ApiResponse<yourProfileResponse>.self,
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self?.profile = profile
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                    continuation.resume()
                }
            }
        }
    }

    @MainActor
    func fetchPosts(userId: Int) async {
        print("[OtherProfile] fetchPosts 호출됨")
        await withCheckedContinuation { continuation in
            useCase.requestUnwrap(
                target: .getYourPost(userId: userId),
                envelope: ApiResponse<yourPostResponse>.self,
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self?.posts = response.result
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                    continuation.resume()
                }
            }
        }
    }

    @MainActor
    func fetchSavedShops(userId: Int) async {
        print("[OtherProfile] fetchSavedShops 호출됨")
        await withCheckedContinuation { continuation in
            useCase.requestUnwrap(
                target: .getYourSavedShop(userId: userId),
                envelope: ApiResponse<YourSavedShopResponse>.self,
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self?.savedShops = response.result
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                    continuation.resume()
                }
            }
        }
    }
}
