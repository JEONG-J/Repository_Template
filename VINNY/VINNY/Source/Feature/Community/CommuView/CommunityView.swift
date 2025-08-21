//
//  CommunityView.swift
//  VINNY
//
//  Created by 한태빈 on 7/4/25.
//

import SwiftUI


struct CommunityView: View {
    @EnvironmentObject var container: DIContainer
    
    init(container: DIContainer) {
        
    }
    
    // MARK: - Networking
    @MainActor
    private func fetchPosts(reset: Bool) async {
        if reset { page = 0 }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let result: PostListResultDTO = try await PostAPITarget.getPosts(page: page, size: size)
            if reset {
                posts = result.posts
            } else {
                posts += result.posts
            }
            // 다음 페이지 로딩이 필요하면 아래 주석 해제
            // page += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @State private var posts: [PostItemDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var page: Int = 0
    @State private var size: Int = 10
    
    var body: some View {
        
        VStack(spacing: 0) {
            /// 상단 고정
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Text("커뮤니티")
                        .font(.suit(.bold, size: 24))
                        .foregroundStyle(Color.contentBase)
                    
                    Spacer()
                    
                    Button(action: {
                        container.navigationRouter.push(to: .PostUploadView)
                    }) {
                        Image("plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                Button(action: {
                    container.navigationRouter.push(to: .SearchView)
                }) {
                    HStack(spacing: 8) {
                        Image("magnifier")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("빈티지샵, 게시글 검색하기")
                            .font(.suit(.regular, size: 16))
                            .foregroundStyle(Color.contentAssistive)
                        
                        Spacer()
                        
                        Image("close")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color.backFillRegular)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
                
                /// 스크롤뷰
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        } else if let err = errorMessage {
                            Text(err)
                                .foregroundStyle(.red)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(posts, id: \.self) { item in
                                PostCardView(item: item)
                                    .environmentObject(container)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 56)
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            }
            .background(Color.backFillStatic)
            .navigationBarBackButtonHidden()
            .task { await fetchPosts(reset: true) }
            .refreshable { await fetchPosts(reset: true) }
        }
    }
    
    #Preview {
        let container = DIContainer()
        CommunityView(container: container)
            .environmentObject(container)
    }

