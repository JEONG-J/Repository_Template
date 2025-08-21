import Foundation
import SwiftUI

@MainActor
final class YourpageViewModel: ObservableObject {
    // MARK: - Dependencies
    private let useCase: DefaultNetworkManager<UsersAPITarget>

    // MARK: - 상태
    @Published var profile: yourProfileResponse?
    @Published var posts: [yourPostResponse] = []
    @Published var savedShops: [YourSavedShopResponse] = []
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

    func fetchProfile(userId: Int) async {
        print("[OtherProfile] fetchProfile 호출됨")
        let result = await withCheckedContinuation { continuation in
            useCase.requestUnwrap(
                target: .getYourProfile(userId: userId),
                envelope: ApiResponse<yourProfileResponse>.self,
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case .success(let profile):
            self.profile = profile
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    func fetchPosts(userId: Int) async {
        print("[OtherProfile] fetchPosts 호출됨")
        let result = await withCheckedContinuation { continuation in
            useCase.requestUnwrap(
                target: .getYourPost(userId: userId),
                envelope: ApiResponse<[yourPostResponse]>.self, // ✅ 배열 형태로 수정
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case .success(let posts):
            self.posts = posts
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    func fetchSavedShops(userId: Int) async {
        print("[OtherProfile] fetchSavedShops 호출됨")
        let result = await withCheckedContinuation { continuation in
            useCase.requestUnwrap(
                target: .getYourSavedShop(userId: userId),
                envelope: ApiResponse<[YourSavedShopResponse]>.self, // ✅ 배열 형태로 수정
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case .success(let shops):
            self.savedShops = shops
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
}
