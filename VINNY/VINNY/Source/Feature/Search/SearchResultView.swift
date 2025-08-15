//
//  SearchResultView.swift
//  VINNY
//
//  Created by 소민준 on 7/31/25.
//

import SwiftUI


struct SearchResultView: View {
    @EnvironmentObject var container: DIContainer
    @State private var searchText: String
    @State private var selectedTab: Int = 0
    @FocusState private var isSearchFieldFocused: Bool
    @StateObject private var vm = SearchResultViewModel()
    
    let tabs = ["샵", "커뮤니티"]
    
    // 더미 샵 데이터
    
    // 더미 유저 데이터
    let users: [UserResult] = [
        .init(name: "홍길동", position: "디자이너"),
        .init(name: "김철수", position: "개발자"),
        .init(name: "이영희", position: "마케터"),
        .init(name: "박민수", position: "기획자")
    ]
    
    init(keyword: String) {
        _searchText = State(initialValue: keyword)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            searchBar

            tabBar
                .padding(.top, 24)

            ScrollView {
                VStack(spacing: 0) {
                    if selectedTab == 0 {
                        ForEach(vm.shops) { shop in
                            VStack(spacing: 0) {
                                SearchResultCell(shops: shop)
                                    .padding(.horizontal, 16)
                                Divider()
                                    .frame(height: 4)
                                    .background(Color.borderDividerRegular)
                            }
                        }
                    } else {
                        if vm.posts.isEmpty {
                            Text("게시글 검색 결과가 없습니다.")
                                .font(.suit(.regular, size: 14))
                                .foregroundColor(.contentAssistive)
                                .padding(.top, 24)
                        } else {
                            CommunityResultCell(posts: vm.posts)
                        }
                    }
                }
            }
            .padding(.top, 12)
        }
        .background(Color.backRootRegular)
        .navigationBarBackButtonHidden()
        .task {
            Task { await vm.bootstrap(keyword: searchText, tab: selectedTab) }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            Task {
                await vm.search(keyword: searchText, tab: newValue)
            }
        }
    }
    
    
    private var header: some View {
        HStack {
            Button(action: {
                container.navigationRouter.pop()
            }) {
                Image("arrowBack")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: 검색창
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image("magnifier")
                .resizable()
                .frame(width: 20, height: 20)
            
            TextField("검색어 입력", text: $searchText)
                .font(.suit(.regular, size: 16))
                .foregroundColor(.white)
                .focused($isSearchFieldFocused)
                .onSubmit {
                    Task{ await vm.search(keyword: searchText, tab: selectedTab)
                    }
                }
            
            Spacer()
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image("close")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backFillRegular)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSearchFieldFocused ? Color.white : Color.clear, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: 탭바
    // MARK: 탭바
    private var tabBar: some View {
        // 전체 구분선을 동일 baseline에 깔기 위해 ZStack의 bottom overlay 사용
        ZStack(alignment: .bottom) {
            HStack(spacing: 32) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut) { selectedTab = index }
                    }) {
                        // 텍스트 하단에 밑줄을 붙이고, 밑줄 높이만큼 하단 여백을 추가
                        Text(tabs[index])
                            .font(.suit(.semibold, size: 16))
                            .foregroundColor(selectedTab == index ? .contentBase : .contentAssistive)
                            .padding(.bottom, 10) // ← 밑줄 공간 확보 (필요시 8~12 사이로 미세조정)
                            .background(alignment: .bottomLeading) {
                                if selectedTab == index {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(height: 2) // 밑줄 두께
                                }
                            }
                    }
                }
                Spacer()
            }
            .padding(.leading, 24)
            .padding(.top, 16)
            // .padding(.bottom, x) 는 불필요 — 각 텍스트에 padding(.bottom, …)로 공간 확보
            
            // 탭 전체 하단 구분선: 선택 밑줄과 같은 baseline에 위치
            Rectangle()
                .fill(Color.borderDividerRegular)
                .frame(height: 1)
                .allowsHitTesting(false)
        }
    }
    
    
}
