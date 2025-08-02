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

    let tabs = ["샵", "커뮤니티"]

    // 더미 샵 데이터
    let shops: [ShopResult] = [
        .init(name: "루트홍대", address: "서울특별시 마포구 양화로 140 B1F", tags: ["캐주얼", "스트릿", "데님"]),
        .init(name: "빈티지산타", address: "서울특별시 마포구 홍익로 19 지하1층", tags: ["아메카지", "캐주얼", "데님"]),
        .init(name: "카마데바", address: "서울특별시 마포구 어울마당로5길 42 B1F", tags: ["하이엔드", "데님", "캐주얼"]),
        .init(name: "옴니피플헤비", address: "서울특별시 마포구 와우산로29나길 18", tags: ["데님", "밀리터리", "스트릿"])
    ]
    
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
                VStack(spacing: 12) {
                    if selectedTab == 0 {
                        ForEach(shops, id: \.name) { shop in
                            ShopResultRow(shop: shop)
                        }
                    } else {
                        ForEach(users, id: \.name) { user in
                            UserResultRow(user: user)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .background(Color.backRootRegular)
        .navigationBarBackButtonHidden()
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
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 6) {
                        Text(tabs[index])
                            .font(.suit(.semibold, size: 15))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(selectedTab == index ? Color.white : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(Color.backFillRegular)
    }
}

struct ShopResult: Identifiable {
    var id: String { name }
    let name: String
    let address: String
    let tags: [String]
}

struct ShopResultRow: View {
    let shop: ShopResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(shop.name)
                .font(.suit(.semibold, size: 16))
                .foregroundColor(.white)

            Text(shop.address)
                .font(.suit(.regular, size: 14))
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                ForEach(["지역"] + shop.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.suit(.medium, size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.backFillRegular)
                        )
                }
            }
        }
        .padding(16)
        .background(Color.backFillRegular)
        .cornerRadius(12)
    }
}

struct UserResult: Identifiable {
    var id: String { name }
    let name: String
    let position: String
}

struct UserResultRow: View {
    let user: UserResult

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.suit(.semibold, size: 16))
                    .foregroundColor(.white)
                Text(user.position)
                    .font(.suit(.regular, size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.backFillRegular)
        .cornerRadius(12)
    }
}
