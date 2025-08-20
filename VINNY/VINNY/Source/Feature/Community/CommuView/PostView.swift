//
//  PostView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct PostView: View {
    @EnvironmentObject var container: DIContainer
    let postId: Int

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var detail: PostDetailDTO?

    @State private var currentIndex: Int = 0
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var likeCount: Int = 0
    
    @State private var isShowingDialog = false
    @State var isShowingDeleteDialog: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                topBarView
                ScrollView { postContentView }
            }
            .background(Color.backFillStatic)

            if isShowingDeleteDialog {
                PostDeleteView(isShowing: $isShowingDeleteDialog)
            }
        }
        .confirmationDialog(
            "게시글",
            isPresented: $isShowingDialog
        ) {
            Button("수정") {
                isShowingDialog = false
                container.editingPostId = postId
                container.navigationRouter.push(to: .PostEditView(postId: postId))
            }
            Button("삭제", role: .destructive) {
                isShowingDialog = false
                container.editingPostId = postId
                isShowingDeleteDialog = true
            }
            Button("취소", role: .cancel) {
                isShowingDialog = false
            }
        }
        .onAppear { container.editingPostId = postId }
        .task(id: postId) { await fetch() }
        .navigationBarBackButtonHidden(true)
    }
    
    private var topBarView: some View {
        ZStack {
            HStack {
                Button (action: {
                    container.navigationRouter.pop()
                }) {
                    Image("arrowBack")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                Spacer()
            }
            Text("게시글")
                .font(.suit(.regular, size: 18))
                .foregroundStyle(Color.contentBase)
        }
        .padding(16)
    }

    private var postContentView: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if isLoading {
                ProgressView()
                    .padding(.top, 24)
            } else if let d = detail {
                headerInfo(d: d)
                imageSection(d: d)
                tagsSection(d: d)
                contentSection(d: d)
                likeBookmarkBarView
            } else if let err = errorMessage {
                Text(err)
                    .foregroundStyle(.red)
                    .padding(.top, 24)
            }
        }
    }

    private func headerInfo(d: PostDetailDTO) -> some View {
        HStack(spacing: 8) {
            URLImageView(d.author.profileImageUrl ?? "")
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(d.author.nickname)
                    .font(.suit(.medium, size: 16))
                    .foregroundStyle(Color.contentBase)
                Text(d.createdAtRelative)
                    .font(.suit(.light, size: 12))
                    .foregroundStyle(Color.contentAdditive)
            }
            .padding(.horizontal, 4)
            Spacer()
            Button(action: {
                isShowingDialog = true
            }) {
                Image("more")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func imageSection(d: PostDetailDTO) -> some View {
        VStack(spacing: 12) {
            if d.images.isEmpty {
                Image("emptyBigImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 440)
                    .clipped()
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(d.images.enumerated()), id: \.offset) { pair in
                        URLImageView(pair.element)
                            .frame(maxWidth: .infinity)
                            .frame(height: 440)
                            .clipped()
                            .tag(pair.offset)
                    }
                }
                .frame(height: 440)
                .padding(.vertical, 4)
                .tabViewStyle(.page(indexDisplayMode: .never))
                HStack(spacing: 4) {
                    ForEach(0..<(max(d.images.count, 1)), id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.gray : Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
                .animation(.easeInOut, value: currentIndex)
                .padding(.top, 8)
            }
        }
    }

    private func tagsSection(d: PostDetailDTO) -> some View {
        HStack(spacing: 6) {
            if let shop = d.shop {
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
            ForEach(d.styles, id: \.self) { st in
                TagComponent(tag: "#\(st.styleName)")
            }
            ForEach(d.brands, id: \.self) { br in
                TagComponent(tag: "#\(br.brandName)")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func contentSection(d: PostDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(d.createdAtRelative)
                .font(.suit(.medium, size: 12))
                .foregroundStyle(Color.contentAssistive)
            Text(d.title)
                .font(.suit(.bold, size: 18))
                .foregroundStyle(Color.contentBase)
            if !d.content.isEmpty {
                Text(d.content)
                    .font(.suit(.light, size: 14))
                    .foregroundStyle(Color.contentAdditive)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var likeBookmarkBarView: some View {
        HStack(spacing: 6) {
            Button(action: {
                Task {
                    do {
                        _ = try await PostAPITarget.performLike(postId: postId, isCurrentLiked: isLiked)
                        if isLiked {
                            isLiked = false
                            likeCount -= 1
                        } else {
                            isLiked = true
                            likeCount += 1
                        }
                    } catch {
                        print("like/unlike failed:", error)
                    }
                }
            }) {
                Image(isLiked ? "likeFill" : "like")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Text("\(likeCount)개")
                .font(.suit(.medium, size: 14))
                .foregroundStyle(Color.contentAdditive)
            Spacer()
            Button(action: {
                Task {
                    do {
                        _ = try await PostAPITarget.performBookmark(postId: postId, isCurrentBookmarked: isBookmarked)
                        isBookmarked.toggle()
                    } catch {
                        print("bookmark failed:", error)
                    }
                }
            }) {
                Image(isBookmarked ? "bookmarkFill" : "bookmark")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    @MainActor
    private func fetch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let d = try await PostAPITarget.fetchPostDetail(postId: postId)
            self.detail = d
            // 동기화: 좋아요/북마크/카운트
            self.isLiked = d.likedByMe
            self.isBookmarked = d.bookmarkedByMe
            self.likeCount = d.likesCount
            self.currentIndex = 0
        } catch {
            self.errorMessage = error.localizedDescription
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
                        Image("emptyImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    @unknown default:
                        Image("emptyImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
            } else {
                Image("emptyImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}
