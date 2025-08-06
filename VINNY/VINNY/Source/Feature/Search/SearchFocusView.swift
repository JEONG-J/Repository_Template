//
//  SearchFocusView.swift
//  VINNY
//
//  Created by 소민준 on 7/26/25.
//

import SwiftUI

private let recentKeywordsKey = "recentKeywordsKey"

struct SearchFocusView: View {
    @EnvironmentObject var container: DIContainer
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var recentKeywords: [String] = UserDefaults.standard.stringArray(forKey: recentKeywordsKey) ?? []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                HStack {
                    Button(action: {
                        container.navigationRouter.pop()
                    }) {
                        Image("arrowBack")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 16)
                    }
                    Spacer()
                }
                Text("검색하기")
                    .font(.suit(.regular, size: 18))
                    .foregroundStyle(Color.contentBase)
            }
            .frame(height: 60)

            // Search Bar
            HStack(spacing: 8) {
                Image("magnifier")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        guard !searchText.isEmpty else { return }
                        addRecentKeyword(searchText)
                        container.navigationRouter.push(to: .SearchResultView(keyword: searchText))
                    }

                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text("빈티지샵, 게시글 검색하기")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.leading, 4)
                    }
                    TextField("", text: $searchText)
                        .focused($isTextFieldFocused)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .tint(.white)
                        .onSubmit {
                            guard !searchText.isEmpty else { return }
                            addRecentKeyword(searchText)
                            container.navigationRouter.push(to: .SearchResultView(keyword: searchText))
                        }
                        .frame(height: 20)
                }

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image("close")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTextFieldFocused ? Color.white : Color.clear, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.backFillRegular))
            )
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .onAppear {
                isTextFieldFocused = true
                updateRecentKeywords()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    recommendedKeywordSection
                    recentKeywordSection
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 4)
            .onTapGesture {
                isTextFieldFocused = false
            }

            Spacer()
        }
        .background(Color.backRootRegular.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func addRecentKeyword(_ keyword: String) {
        SearchKeywordManager.shared.add(keyword)
        updateRecentKeywords()
    }

    private func updateRecentKeywords() {
        recentKeywords = SearchKeywordManager.shared.get()
    }

    private var recommendedKeywordSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("추천 검색어")
                .font(.suit(.semibold, size: 16))
                .foregroundColor(.white)
                .padding(.top, 18)
                .padding(.bottom, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["홍대 데님", "칼하트", "하이엔드 빈티지", "폴로", "슈프림"], id: \.self) { keyword in
                        Text(keyword)
                            .font(.suit(.medium, size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.backFillRegular)
                            )
                            .foregroundStyle(Color.contentBase)
                            .onTapGesture {
                                searchText = keyword
                                addRecentKeyword(keyword)
                                container.navigationRouter.push(to: .SearchResultView(keyword: keyword))
                            }
                    }
                }
                .padding(.vertical, 4)
                Spacer().frame(height: 20)
                Rectangle()
                    .fill(Color.borderDividerRegular)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.horizontal)
                Spacer().frame(height: 4)
            }
        }
    }

    private var recentKeywordSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("최근 검색어")
                    .font(.suit(.semibold, size: 16))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    SearchKeywordManager.shared.clearAll()
                    updateRecentKeywords()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.gray)
                        Text("모두 삭제")
                            .font(.suit(.regular, size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 16)

            VStack(spacing: 20) {
                ForEach(recentKeywords, id: \.self) { keyword in
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text(keyword)
                            .font(.suit(.regular, size: 15))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            SearchKeywordManager.shared.remove(keyword)
                            updateRecentKeywords()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        searchText = keyword
                        addRecentKeyword(keyword)
                        container.navigationRouter.push(to: .SearchResultView(keyword: keyword))
                    }
                }
            }
        }
    }
}
