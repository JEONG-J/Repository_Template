//
//  SearchView.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//



import SwiftUI

struct SearchView: View {
    @EnvironmentObject var container: DIContainer
    @Environment(\.presentationMode) var presentationMode

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            header
            searchBar
                .padding(.top, 18)
            ScrollView {
                categorySection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
            }
        }
        .background(Color.backFillStatic.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        ZStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("arrowBack")
                        .font(.system(size: 24, weight: .medium))
                }
                Spacer()
            }

            Text("검색하기")
                .font(.suit(.bold, size: 24))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var searchBar: some View {
        Button(action: {
            container.navigationRouter.push(to: .SearchFocusView)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("카테고리로 모아보기")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 18)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(CategoryItem.sampleList) { category in
                    Button {
                        let kw = category.name
                        SearchKeywordManager.shared.add(kw)
                        container.navigationRouter.push(to: .SearchResultView(keyword: kw)) // 그대로
                    } label: {
                        CategoryItemView(categoryItem: category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 16)
        }
    }
}
