import SwiftUI

struct YourProfileView: View {
    let userId: Int
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var viewModel: YourpageViewModel

    @State private var selectedTab: Int = 0
    private let filters = ["게시물", "찜한 샵"]

    var body: some View {
        ZStack {
            Color("BackRootRegular")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단 프로필 헤더
                YourTopsideProfileView()

                // 탭 필터
                ProfileSelectedFilter(
                    selectedIndex: $selectedTab,
                    filters: filters,
                    counts: [
                        viewModel.profile?.postCount ?? 0,
                        viewModel.profile?.bookmarkCount ?? 0
                    ]
                )

                // 선택된 탭에 따른 뷰
                Group {
                    switch selectedTab {
                    case 0:
                        YourProfilePostView()
                    case 1:
                        YourSavedShopView()
                    default:
                        EmptyView()
                    }
                }
                .padding(.top, 16)
            }
        }
        .task {
            await viewModel.fetchAll(userId: userId)
            await viewModel.fetchPosts(userId: userId)
        }
        .onChange(of: selectedTab) {
            Task {
                switch selectedTab {
                case 0:
                    await viewModel.fetchPosts(userId: userId)
                case 1:
                    await viewModel.fetchSavedShops(userId: userId)
                default:
                    break
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
