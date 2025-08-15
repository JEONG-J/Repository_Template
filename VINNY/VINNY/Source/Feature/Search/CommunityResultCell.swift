import SwiftUI
import Foundation

// 커뮤니티 결과 셀: 게시글 이미지 그리드
struct CommunityResultCell: View {
    let posts: [PostSearchResultDTO]             // ← API 결과 주입
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)

    var body: some View {
        // 부모(SearchResultView)에 ScrollView가 있으므로 여기선 LazyVGrid만
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(posts, id: \.id) { post in
                ForEach(post.imageUrls ?? [], id: \.self) { url in
                    PostImageTile(urlString: url)
                }
            }
        }
        .padding(.top, 1)
    }
}

// 작은 타일로 분리해서 타입체크 부담↓
private struct PostImageTile: View {
    let urlString: String

    var body: some View {
        if let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Rectangle().fill(Color.gray.opacity(0.2))
                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                } else {
                    Rectangle().fill(Color.gray.opacity(0.15))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipped()
        } else {
            Rectangle().fill(Color.gray.opacity(0.2))
                .overlay(Image(systemName: "exclamationmark.triangle").foregroundStyle(.gray))
                .aspectRatio(1, contentMode: .fit)
        }
    }
}
//굳
