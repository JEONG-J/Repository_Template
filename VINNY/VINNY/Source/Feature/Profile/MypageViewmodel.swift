import Foundation
import SwiftUI

final class MypageViewModel: ObservableObject {
    private let mypageUseCase: DefaultNetworkManager<MypageAPITarget>
    
    // MARK: - 상태
    @Published var profile: MypageProfileResponse?
    @Published var writtenPosts: [MypageWrittenPostsResponse] = []
    @Published var savedPosts: [MypageSavedPostsResponse] = []
    @Published var savedShops: [MypageSavedShopsResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(useCase: DefaultNetworkManager<MypageAPITarget>) {
        self.mypageUseCase = useCase
    }
    
    // MARK: - 프로필 조회
    func fetchProfile()  {
        isLoading = true
        print("[Mypage] fetchProfile 호출됨")
        mypageUseCase.requestUnwrap(
            target: .getProfile,
            envelope: ApiResponse<MypageProfileResponse>.self,
            isSuccess: \.isSuccess,
            code: \.code,
            message: \.message,
            result: \.result
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("fetchProfile result: \(result)")
                switch result {
                case .success(let profile):
                    self?.profile = profile
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("fetchProfile error: \(error)")
                }
            }
        }
    }
    
    // MARK: - 게시글 목록
    func fetchWrittenPosts() {
        print("[Mypage] fetchWrittenPosts 호출됨")
        mypageUseCase.requestUnwrap(
            target: .getWrittenPosts,
            envelope: ApiResponse<[MypageWrittenPostsResponse]>.self,
            isSuccess: \.isSuccess,
            code: \.code,
            message: \.message,
            result: \.result
        ) { [weak self] result in
            DispatchQueue.main.async {
                print("fetchWrittenPosts result: \(result)")
                switch result {
                case .success(let posts):
                    self?.writtenPosts = posts
                case .failure(let error):
                    print("fetchWrittenPosts error: \(error)")
                }
            }
        }
    }
    
    // MARK: - 저장한 게시글
    func fetchSavedPosts() {
        print("[Mypage] fetchSavedPosts 호출됨")
        mypageUseCase.requestUnwrap(
            target: .getSavedPosts,
            envelope: ApiResponse<[MypageSavedPostsResponse]>.self,
            isSuccess: \.isSuccess,
            code: \.code,
            message: \.message,
            result: \.result
        ) { [weak self] result in
            DispatchQueue.main.async {
                print("fetchSavedPosts result: \(result)")
                switch result {
                case .success(let posts):
                    self?.savedPosts = posts
                case .failure(let error):
                    print("fetchSavedPosts error: \(error)")
                }
            }
        }
    }
    
    // MARK: - 찜한 샵
    func fetchSavedShops() {
        print("[Mypage] fetchSavedShops 호출됨")
        mypageUseCase.requestUnwrap(
            target: .getSavedShops,
            envelope: ApiResponse<[MypageSavedShopsResponse]>.self,
            isSuccess: \.isSuccess,
            code: \.code,
            message: \.message,
            result: \.result
        ) { [weak self] result in
            DispatchQueue.main.async {
                print("fetchSavedShops result: \(result)")
                switch result {
                case .success(let shops):
                    self?.savedShops = shops
                case .failure(let error):
                    print("fetchSavedShops error: \(error)")
                }
            }
        }
    }
    
    // MARK: - 기존 프로필 수정
    func updateProfile(nickname: String, comment: String) {
        let dto = MyPageNicknameDTO(nickname: nickname, comment: comment)
        print("[Mypage] updateProfile 호출됨 - 닉네임: \(nickname), 코멘트: \(comment)")
        mypageUseCase.requestUnwrap(
            target: .updateProfile(dto: dto),
            envelope: ApiResponse<MypageUpdateProfileResponse>.self,
            isSuccess: \.isSuccess,
            code: \.code,
            message: \.message,
            result: \.result
        ) { [weak self] result in
            DispatchQueue.main.async {
                print("updateProfile result: \(result)")
                switch result {
                case .success(let updated):
                    self?.profile = MypageProfileResponse(
                        userId: updated.userId,
                        nickname: updated.nickname,
                        profileImage: updated.profileImage,
                        backgroundImage: updated.backgroundImage,
                        comment: updated.comment,
                        postCount: self?.profile?.postCount ?? 0,
                        likedShopCount: self?.profile?.likedShopCount ?? 0,
                        savedCount: self?.profile?.savedCount ?? 0
                    )
                case .failure(let error):
                    print("updateProfile error: \(error)")
                }
            }
        }
    }
    
    // MARK: - 프로필 이미지 업로드
    @MainActor
    func uploadProfileImage(data: Data) async -> Bool {
        var didSucceed = false
        
        await withCheckedContinuation { continuation in
            mypageUseCase.requestUnwrap(
                target: .updateProfileImage(image: data),
                envelope: ApiResponse<MypageUpdateProfileImageResponse>.self,
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updated):
                        self?.profile?.profileImage = updated.profileImage
                        didSucceed = true
                    case .failure(let error):
                        print(" uploadProfileImage error: \(error)")
                    }
                    continuation.resume()
                }
            }
        }
        
        return didSucceed
    }
    
    // 배경 이미지 업로드
    @MainActor
    func uploadBackgroundImage(data: Data) async -> Bool {
        var didSucceed = false
        
        await withCheckedContinuation { continuation in
            mypageUseCase.requestUnwrap(
                target: .updateBackground(image: data),
                envelope: ApiResponse<MypageUpdateBackgroundImageResponse>.self,
                isSuccess: \.isSuccess,
                code: \.code,
                message: \.message,
                result: \.result
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updated):
                        self?.profile?.backgroundImage = updated.backgroundImage
                        didSucceed = true
                    case .failure(let error):
                        print("uploadBackgroundImage error: \(error)")
                    }
                    continuation.resume()
                }
            }
        }
        
        return didSucceed
    }
}
