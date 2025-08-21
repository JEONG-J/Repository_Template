import SwiftUI
import Kingfisher

struct YourTopsideProfileView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var viewModel: YourpageViewModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: viewModel.profile?.backgroundImageURL ?? ""))
                .placeholder {
                    ProgressView()
                }
                .onFailureImage(UIImage(named: "noneBackGround"))
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.width
                )
                .clipped()

            // 하단 프로필 정보
            HStack(spacing: 8) {
                KFImage(URL(string: viewModel.profile?.profileImageURL ?? ""))
                    .placeholder {
                        ProgressView()
                    }
                    .onFailureImage(UIImage(named: "noneProfile"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
//                        .padding(.leading, 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.profile?.nickname ?? "")
                        .font(.suit(.medium, size: 18))
                        .foregroundStyle(Color("ContentBase"))

                    Text(viewModel.profile?.comment ?? "")
                        .font(.suit(.regular, size: 12))
                        .foregroundStyle(Color("ContentAdditive"))
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, 10)
        }
    }
}
