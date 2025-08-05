//
//  PostView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct PostView: View {
    @EnvironmentObject var container: DIContainer
        
    init(container: DIContainer) {
        
    }
    
    @State private var currentIndex: Int = 0
    private var postImages: [String] = ["post2", "post2", "post2"]
    
    private var shopName: String = "스테이블 그라운드 합정"
    private var tags: [String] = ["#빈티지", "#스트릿", "#레더"]
    
    private var postTime: String = "3시간 전 | 2025년 5월 9일"
    private var title: String = "오늘의 폴로 코디"
    private var content: String = "봄에 내는 가을 무드 ㅎㅎ"
    private var likeCount: Int = 259
    
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    
    @State private var isShowingDialog = false
    @State var isShowingDeleteDialog: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - 상단 고정 바
                ZStack {
                    HStack {
                        Button (action: {
                            print("뒤로 가기")
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
                
                // MARK: - 스크롤뷰
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            Image("post1") // 프로필 이미지
                                .resizable()
                                .frame(width: 40, height: 40)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text("김지훈") // 닉네임
                                    .font(.suit(.medium, size: 16))
                                    .foregroundStyle(Color.contentBase)
                                Text("소개글") // 소개글
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
                        
                        /// post 페이지네이션
                        VStack(spacing: 12) {
                            TabView(selection: $currentIndex) {
                                ForEach(0..<postImages.count, id: \.self) { index in
                                    Image(postImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 440)
                                        .clipped()
                                }
                            }
                            .frame(height: 440)
                            .padding(.vertical, 4)
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            
                            /// 커스텀 인디케이터( 커스텀 안 쓰니 이미지 안으로 들어가서 커스텀 쓰기로 함)
                            HStack(spacing: 4) {
                                ForEach(0..<postImages.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentIndex ? Color.gray : Color.gray.opacity(0.3))
                                        .frame(width: 4, height: 4)
                                }
                            }
                            .animation(.easeInOut, value: currentIndex)
                            .padding(.top, 8)
                        }
                        
                        /// tags
                        HStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Image("mapPinFill")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text("\(shopName)") // 샵 이름 태그
                                    .font(.suit(.medium, size: 12))
                                    .foregroundStyle(Color.contentAdditive)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(Color.backFillRegular)
                            )
                            
                            ForEach(tags, id: \.self) { category in
                                TagComponent(tag: category)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(postTime)")
                                .font(.suit(.medium, size: 12))
                                .foregroundStyle(Color.contentAssistive)
                            Text("\(title)")
                                .font(.suit(.bold, size: 18))
                                .foregroundStyle(Color.contentBase)
                            Text("\(content)")
                                .font(.suit(.light, size: 14))
                                .foregroundStyle(Color.contentAdditive)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        HStack(spacing: 6) {
                            Button(action: {
                                isLiked.toggle()
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
                                isBookmarked.toggle()
                            }) {
                                Image(isBookmarked ? "bookmarkFill" : "bookmark")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color.backFillStatic)
            .confirmationDialog(
                title,
                isPresented: $isShowingDialog
            ) {
                Button("수정") {
                    
                }
                Button("삭제", role: .destructive) {
                    isShowingDialog = false
                    isShowingDeleteDialog = true
                }
                Button("취소", role: .cancel) {
                    isShowingDialog = false
                }
            }
            
            if isShowingDeleteDialog {
                PostDeleteView(isShowing: $isShowingDeleteDialog)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
