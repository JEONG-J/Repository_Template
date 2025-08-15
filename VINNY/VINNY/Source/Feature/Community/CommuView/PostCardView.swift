//
//  PostCardView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct PostCardView: View {
    @EnvironmentObject var container: DIContainer

    let item: PostItemDTO

    @State private var currentIndex: Int = 0
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var likeCount: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header: author
                HStack(spacing: 8) {
                    URLImageView(item.author.profileImageUrl ?? "")
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.author.nickname)
                            .font(.suit(.medium, size: 16))
                            .foregroundStyle(Color.contentBase)
                        Text(item.author.comment ?? "")
                            .font(.suit(.light, size: 12))
                            .foregroundStyle(Color.contentAdditive)
                    }
                    .padding(.horizontal, 4)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                // Images: page style
                VStack(spacing: 0) {
                    if item.images.isEmpty {
                        Image("emptyBigImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 282)
                            .clipped()
                            .padding(.vertical, 4)
                    } else {
                        TabView(selection: $currentIndex) {
                            ForEach(Array(item.images.enumerated()), id: \.offset) { pair in
                                let urlString = pair.element
                                URLImageView(urlString)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 282)
                                    .clipped()
                                    .tag(pair.offset)
                            }
                        }
                        .frame(height: 282)
                        .padding(.vertical, 4)
                        .tabViewStyle(.page(indexDisplayMode: .never))

                        // custom indicators
                        HStack(spacing: 4) {
                            ForEach(0 ..< max(item.images.count, 1), id: \.self) { index in
                                Circle()
                                    .fill(index == currentIndex ? Color.gray : Color.gray.opacity(0.3))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .animation(.easeInOut, value: currentIndex)
                        .padding(.top, 8)
                    }
                }

                // tags row (shop/style/brand)
                HStack(spacing: 6) {
                    if let shop = item.shop {
                        HStack(spacing: 4) {
                            Image("mapPinFill")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text(shop.shopName)
                                .font(.suit(.medium, size: 12))
                                .foregroundStyle(Color.contentAdditive)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(Color.backFillRegular)
                        )
                    }

                    if let style = item.style {
                        TagComponent(tag: "#\(style.styleName)")
                    }
                    if let brand = item.brand {
                        TagComponent(tag: "#\(brand.brandName)")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                // meta + title + content
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.createdAtRelative)
                        .font(.suit(.medium, size: 12))
                        .foregroundStyle(Color.contentAssistive)
                    Text(item.title)
                        .font(.suit(.bold, size: 18))
                        .foregroundStyle(Color.contentBase)
                    if !item.content.isEmpty {
                        Text(item.content)
                            .font(.suit(.light, size: 14))
                            .foregroundStyle(Color.contentAdditive)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                container.navigationRouter.push(to: .PostView(id: item.postId))
            }

            // like/bookmark row
            HStack(spacing: 6) {
                Button(action: {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }) {
                    Image(isLiked ? "likeFill" : "like")
                        .resizable()
                        .frame(width: 20, height: 20)
                }

                Text("\(likeCount)개")
                    .font(.suit(.medium, size: 14))
                    .foregroundStyle(Color.contentAdditive)
                Spacer()

                Button(action: {
                    isBookmarked.toggle()
                }) {
                    Image(isBookmarked ? "bookmarkFill" : "bookmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backFillRegular)
        )
        .onAppear {
            // 초기 상태를 서버 값으로 동기화
            self.isLiked = item.likedByMe
            self.isBookmarked = item.bookmarkedByMe
            self.likeCount = item.likesCount
        }
    }
}

private struct URLImageView: View {
    private let urlString: String
    init(_ urlString: String) { self.urlString = urlString }

    var body: some View {
        Group {
            if let url = URL(string: urlString), !urlString.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack { Color.clear; ProgressView() }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image("emptyBigImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    @unknown default:
                        Image("emptyBigImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
            } else {
                Image("emptyBigImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}
