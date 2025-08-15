import Foundation
import SwiftUI

/// 마이페이지 도메인 상태/사이드이펙트 관리 ViewModel
/// - Handles: 프로필 조회/수정, 작성/저장 게시글, 찜한 샵 조회, 이미지 업로드
/// - Threading: 콜백 기반 네트워크는 메인 디스패치로 상태 갱신
final class MypageViewModel: ObservableObject {
    // MARK: - Dependencies
    private let mypageUseCase: DefaultNetworkManager<MypageAPITarget>
    
    // MARK: - 상태
    @Published var profile: MypageProfileResponse?
    @Published var writtenPosts: [MypageWrittenPostsResponse] = []
    @Published var savedPosts: [MypageSavedPostsResponse] = []
    @Published var savedShops: [MypageSavedShopsResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(useCase: DefaultNetworkManager<MypageAPITarget>) {
        self.mypageUseCase = useCase
    }
    
    // MARK: - APIs

    /// 프로필 조회
    /// - Effects: isLoading 토글, profile/errorMessage 업데이트
    func fetchProfile()  {
        isLoading = true
        print("[Mypage] fetchProfile 호출됨")
        // TODO: os.Logger로 전환, Print 제거
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
                    // TODO: 에러 Toast/Alert 바인딩
                }
            }
        }
    }
    
    /// 내가 쓴 게시글 목록
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
    
    /// 저장한 게시글 목록
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
    
    /// 찜한 샵 목록
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
    
    /// 텍스트 기반 프로필 수정(닉네임/소개)
    /// - Note: 성공 시 로컬 profile을 최신 데이터로 갱신
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
                    // TODO: 성공 토스트/해당 화면 리프레시 정책 합의
                case .failure(let error):
                    print("updateProfile error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Uploads

   /// 프로필 이미지 업로드
   /// - Returns: 성공 여부 Bool
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
                        // TODO: 실패 UX(토스트/재시도)
                    }
                    continuation.resume()
                }
            }
        }
        
        return didSucceed
    }
    
    /// 배경 이미지 업로드
    /// - Returns: 성공 여부 Bool
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
    // TODO: 전체 API를 async/await 기반으로 리팩터링하고 @MainActor 함수에서 직접 await로 상태 갱신
}
