import SwiftUI

struct MyProfileView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var viewModel: MypageViewModel

    @State private var selectedTab: Int = 0
    private let filters = ["게시물", "찜한 샵", "저장함"]

    var body: some View {
        VStack(spacing: 0) {
            // 상단 프로필 헤더
            TopsideProfileView()

            // 탭 필터
            ProfileSelectedFilter(
                selectedIndex: $selectedTab,
                filters: filters,
                counts: [
                    viewModel.profile?.postCount ?? 0,
                    viewModel.profile?.likedShopCount ?? 0,
                    viewModel.profile?.savedCount ?? 0
                ]
            )

            // 선택된 탭에 따른 뷰
            Group {
                switch selectedTab {
                case 0:
                    ProfilePostView()
                case 1:
                    SavedShopView()
                case 2:
                    SavedPostView()
                default:
                    EmptyView()
                }
            }
            .padding(.top, 16)
        }
        .onAppear {
            print("MyProfileView onAppear - fetch 초기화")
            viewModel.fetchProfile()
            viewModel.fetchWrittenPosts() // 초기값이 0 (게시물)일 때 먼저 호출
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            switch newValue {
            case 0:
                viewModel.fetchWrittenPosts()
            case 1:
                viewModel.fetchSavedShops()
            case 2:
                viewModel.fetchSavedPosts()
            default:
                break
            }
        }
        .navigationBarBackButtonHidden()
    }
}
