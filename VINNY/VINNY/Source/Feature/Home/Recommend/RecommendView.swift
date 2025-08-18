//
//  RecommendView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct RecommendView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer) {
        
    }
//    let shopName: String
    var shopAddress: String = "샵 주소"
    var shopIG: String = "vintageplus_trendy"
    var shopTime: String = "12:00 ~ 23:00"
    var categories: [String] = ["🛠️ 워크웨어", "👕 캐주얼", "💼 하이엔드"]
    @State private var forYouShops: [ShopForYouResponseDTO] = []
        
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                HStack {
                    Text("취향저격 샵 추천")
                        .font(.suit(.bold, size: 20))
                        .foregroundStyle(Color.contentBase)
                    
                    Spacer()
                    
                    Text("주에 한 번 업데이트 되어요")
                        .font(.suit(.light, size: 14))
                        .foregroundStyle(Color.contentAdditive)
                }
                .padding(.top, 14)
                .padding(.bottom, 6)
                .padding(.horizontal, 6)
                
                ForEach(forYouShops, id: \.id) { shop in
                    recommendShopCard(shop: shop)
                        .padding(.vertical, 16)
                }
            }
        }
        .task {
            do {
                forYouShops = try await ShopAPITarget.getForYou(limit: 3)
            } catch {
                print("for-you error:", error)
            }
        }
    }
    
    private func recommendShopCard(shop: ShopForYouResponseDTO) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: shop.logoImage)) { img in
                    img.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 40, height: 40)
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(shop.name)
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color.contentBase)
                    Text(shop.address ?? "-")
                        .font(.suit(.light, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                .padding(.horizontal, 4)
                Spacer()
                Button(action: {
                    container.navigationRouter.push(to: .ShopView(id: 0)) // TODO: 실제 shopId로 교체
                }) {
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            HStack(spacing: 2) {
                Image("instargram")
                    .resizable()
                    .frame(width: 16, height: 16)
                Text("인스타그램")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.contentAssistive)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: 82, alignment: .leading)
                Text(shop.instagram ?? "-")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.contentAdditive)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            
            HStack(spacing: 2) {
                Image("time")
                    .resizable()
                    .frame(width: 16, height: 16)
                Text("영업 시간")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.contentAssistive)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: 82, alignment: .leading)
                Text("\(shop.openTime ?? "-") ~ \(shop.closeTime ?? "-")")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.contentAdditive)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            
            HStack(spacing: 6) {
                ForEach(shop.shopVintageStyleList ?? [], id: \.id) { style in
                    TagComponent(tag: style.vintageStyleName)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            AsyncImage(url: URL(string: shop.images.url)) { img in
                img.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: 184)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.backFillRegular)
        )
    }
}
