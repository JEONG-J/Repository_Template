import SwiftUI
import Kingfisher

struct YourSavedShopView: View {
    @EnvironmentObject var viewModel: YourpageViewModel

    var body: some View {
        if viewModel.savedShops.isEmpty {
            EmptyView()
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.savedShops, id: \.shopId) { shop in
                        YourShopCardView(shop: shop)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
            }
            .background(Color("BackRootRegular"))
        }
    }
}

struct YourShopCardView: View {
    let shop: YourSavedShopResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 상단: 이미지 + 이름/주소 + 하트
            HStack(spacing: 8) {
                KFImage(URL(string: shop.imageUrls.first ?? ""))
                    .placeholder {
                        Image("emptyImage")
                            .resizable()
                    }
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(shop.name)
                        .font(.suit(.medium, size: 18))
                        .foregroundStyle(Color.contentBase)
                    Text(shop.address)
                        .font(.suit(.light, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }

                Spacer()

                Image("likeFill") // 고정된 찜 이미지
                    .resizable()
                    .frame(width: 24, height: 24)
//                Button(action: {
//                    container.navigationRouter.push(to: .ShopView(id: shop.shopId))
//                }) {
//                    Image("chevron.right")
//                        .resizable()
//                        .frame(width: 16, height: 16)
//                }
            }

            // 지역 + 스타일 태그들
            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image("mapPin")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text(shop.region)
                        .font(.suit(.medium, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.backFillRegular)
                )

                ForEach(shop.styles, id: \.self) { style in
                    TagComponent(tag: "#\(style)")
                }
            }
            .padding(.vertical, 8)

            // 썸네일 이미지
            KFImage(URL(string: shop.imageUrls.first ?? ""))
                .placeholder {
                    Image("emptyBigImage")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 104)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.vertical, 8)

            Divider()
                .padding(.bottom, 12)
        }
    }
}

#Preview {
    YourSavedShopView()
        .environmentObject(YourpageViewModel(
            useCase: DefaultNetworkManager<UsersAPITarget>()
        ))
}
