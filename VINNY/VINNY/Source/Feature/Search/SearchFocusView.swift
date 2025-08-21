//
//  SearchFocusView.swift
//  VINNY
//
//  Created by 소민준 on 7/26/25.
//

import SwiftUI


struct SearchFocusView: View {
    @State private var shopSuggestions: [AutoCompleteShopDTO] = []
    @State private var brandSuggestions: [AutoCompleteBrandDTO] = []
    @State private var isLoadingSuggestions: Bool = false
    @State private var searchTask: Task<Void, Never>? = nil
    @EnvironmentObject var container: DIContainer
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var recentKeywords: [String] = []

    private var hasSuggestions: Bool {
        !brandSuggestions.isEmpty || !shopSuggestions.isEmpty
    }

    // MARK: - 로직 변경: 로딩 중일 때는 '결과 없음' 상태가 아니도록 수정
    private var shouldShowEmptyState: Bool {
        // 로딩이 끝났고, 검색어는 있는데, 제안 결과가 없을 때만 '결과 없음'을 표시
        !isLoadingSuggestions && !searchText.trimmingCharacters(in: .whitespaces).isEmpty && !hasSuggestions
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (변경 없음)
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

            // Search Bar (변경 없음)
            HStack(spacing: 8) {
                Image("magnifier")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        submitSearch(keyword: searchText)
                    }

                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text("빈티지샵, 게시글 검색하기")
                            .font(.suit(.regular, size: 16))
                            .foregroundStyle(Color.contentAssistive)
                            .padding(.leading, 4)
                    }
                    TextField("", text: $searchText)
                        .focused($isTextFieldFocused)
                        .font(.suit(.regular, size: 16))
                        .foregroundStyle(Color.contentBase)
                        .tint(Color.contentBase)
                        .onSubmit {
                            submitSearch(keyword: searchText)
                        }
                        .onChange(of: searchText) { _, newValue in
                            handleSearchTextChange(for: newValue)
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
                    .stroke(isTextFieldFocused ? Color.contentBase : Color.clear, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.backFillRegular))
            )
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .task {
                isTextFieldFocused = true
                updateRecentKeywords()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) { // spacing 추가로 섹션 간 간격 조절
                    // --- MARK: UI 구조 및 상태 표시 로직 전체 수정 ---
                    
                    // 1) 상태에 따른 뷰 분기 처리
                    if isLoadingSuggestions {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if shouldShowEmptyState {
                        emptyStateView
                    } else if hasSuggestions {
                        suggestionsSection // 자동완성 섹션
                    }

                    // 2) 추천 및 최근 검색어 (항상 표시)
                    recommendedKeywordSection
                    
                    Rectangle()
                        .fill(Color.borderDividerRegular)
                        .frame(height: 1)
                        .padding(.vertical, 2)

                    recentKeywordSection
                }
                .padding(.horizontal, 16) // 전체 컨텐츠에 좌우 패딩 적용
            }
            .padding(.top, 8)
            .onTapGesture {
                isTextFieldFocused = false
            }

            Spacer()
        }
        .background(Color.backRootRegular.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // --- MARK: 자동완성 UI를 위한 새로운 뷰 빌더 ---
    @ViewBuilder
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 브랜드 자동완성
            ForEach(brandSuggestions, id: \.keyword) { suggestion in
                brandSuggestionRow(for: suggestion)
            }

            // 샵 자동완성
            ForEach(shopSuggestions, id: \.name) { suggestion in
                shopSuggestionRow(for: suggestion)
            }
        }
        .padding(8) // 내용물과 배경 사이에 패딩
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backFillRegular)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut, value: hasSuggestions)
    }

    private func brandSuggestionRow(for suggestion: AutoCompleteBrandDTO) -> some View {
        Button {
            submitSearch(keyword: suggestion.keyword)
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: suggestion.imageUrl)) { img in
                    img.resizable()
                } placeholder: {
                    Image("emptyBrand").resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                Text(suggestion.keyword)
                    .font(.suit(.regular, size: 16))
                    .foregroundStyle(Color.contentBase)
                Spacer()
            }
            .padding(10)
        }
    }

    private func shopSuggestionRow(for suggestion: AutoCompleteShopDTO) -> some View {
        Button {
            submitSearch(keyword: suggestion.name)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: suggestion.imageUrl)) { img in
                    img.resizable()
                } placeholder: {
                    Image("emptyImage").resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.name)
                        .font(.suit(.regular, size: 16))
                        .foregroundStyle(Color.contentBase)
                    Text(suggestion.address)
                        .font(.suit(.light, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                Spacer()
            }
            .padding(10)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "face.dashed")
                .font(.system(size: 40))
                .foregroundStyle(Color.contentAssistive)
            Text("표시할 내용이 없어요!")
                .font(.suit(.regular, size: 14))
                .foregroundStyle(Color.contentAssistive)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // 추천, 최근 검색어 섹션은 기존 코드와 거의 동일
    private var recommendedKeywordSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("추천 검색어")
                .font(.suit(.semibold, size: 16))
                .foregroundStyle(Color.contentBase)
                .padding(.vertical, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["홍대 데님","칼하트","하이엔드 빈티지","폴로","슈프림"], id: \.self) { keyword in
                        Text(keyword)
                            .font(.suit(.medium, size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.backFillRegular))
                            .foregroundStyle(Color.contentBase)
                            .onTapGesture {
                                submitSearch(keyword: keyword)
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var recentKeywordSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("최근 검색어")
                    .font(.suit(.semibold, size: 16))
                    .foregroundStyle(Color.contentBase)
                Spacer()
                if !recentKeywords.isEmpty {
                    Button(action: {
                        SearchKeywordManager.shared.clearAll()
                        updateRecentKeywords()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .resizable().frame(width: 12, height: 12)
                            Text("모두 삭제")
                                .font(.suit(.regular, size: 14))
                        }
                        .foregroundStyle(Color.contentAssistive)
                    }
                }
            }
            .padding(.vertical, 16)

            VStack(spacing: 20) {
                ForEach(recentKeywords, id: \.self) { keyword in
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.contentAssistive)
                        Text(keyword)
                            .font(.suit(.regular, size: 15))
                            .foregroundStyle(Color.contentBase)
                        Spacer()
                        Button(action: {
                            SearchKeywordManager.shared.remove(keyword)
                            updateRecentKeywords()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.contentAssistive)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        submitSearch(keyword: keyword)
                    }
                }
            }
        }
    }
}

// MARK: - Functions
private extension SearchFocusView {
    
    func submitSearch(keyword: String) {
        guard !keyword.isEmpty else { return }
        searchText = keyword
        addRecentKeyword(keyword)
        container.navigationRouter.push(to: .SearchResultView(keyword: keyword))
        brandSuggestions = []
        shopSuggestions = []
        isTextFieldFocused = false
    }

    func addRecentKeyword(_ keyword: String) {
        SearchKeywordManager.shared.add(keyword)
        updateRecentKeywords()
    }

    func updateRecentKeywords() {
        recentKeywords = SearchKeywordManager.shared.get()
    }

    func handleSearchTextChange(for newValue: String) {
        searchTask?.cancel()

        guard !newValue.trimmingCharacters(in: .whitespaces).isEmpty else {
            shopSuggestions = []
            brandSuggestions = []
            isLoadingSuggestions = false
            return
        }

        searchTask = Task {
            do {
                // 로딩 상태 시작
                await MainActor.run { isLoadingSuggestions = true }
                
                // 0.25초 디바운스
                try await Task.sleep(nanoseconds: 250_000_000)
                
                // API 호출
                await fetchSuggestions(keyword: newValue)
            } catch {
                // Task가 취소되면 여기로 옴
                print("Search task cancelled.")
            }
        }
    }
    
    @MainActor
    func fetchSuggestions(keyword: String) async {
        // isLoadingSuggestions는 호출 전에 true로 설정
        defer { isLoadingSuggestions = false }

        do {
            async let brandsTask = AutoCompleteAPITarget.fetchBrandAutoComplete(keyword: keyword)
            async let shopsTask = AutoCompleteAPITarget.fetchShopAutoComplete(keyword: keyword)

            let (brands, shops) = try await (brandsTask, shopsTask)
            self.brandSuggestions = brands
            self.shopSuggestions = shops
        } catch {
            print("Failed to fetch suggestions: \(error)")
            self.brandSuggestions = []
            self.shopSuggestions = []
        }
    }
}
