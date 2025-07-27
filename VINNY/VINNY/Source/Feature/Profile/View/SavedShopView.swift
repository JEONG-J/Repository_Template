//
//  SavedShopView\.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import SwiftUI

struct SavedShopView: View {
    private var shopData: [Shop] = Array(repeating: Shop(name: "샵 이름", address: "샵 주소", isLiked: true, categories: ["카테고리1", "카테고리2", "카테고리3"]), count: 9)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(shopData.indices, id: \.self) { index in
                    ShopCardView(shop: shopData[index])
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
        }
    }
}

struct ShopCardView: View {
    @State var shop: Shop

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 상단: 이미지 + 이름/주소 + 하트 버튼
            HStack(spacing: 8) {
                Image("emptyImage")
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

                Button {
                    shop.isLiked.toggle()
                } label: {
                    Image(shop.isLiked ? "likeFill" : "like")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }

            // 중간: 태그들
            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image("mapPin")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("지역")
                        .font(.suit(.medium, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.backFillRegular)
                )

                ForEach(shop.categories, id: \.self) { category in
                    TagComponent(tag: "#\(category)")
                }
            }
            .padding(.vertical, 8)

            // 하단: 큰 썸네일
            Image("emptyBigImage")
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

// 예시 모델
struct Shop {
    var name: String
    var address: String
    var isLiked: Bool
    var categories: [String]
}


#Preview {
    SavedShopView()
}
