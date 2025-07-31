//
//  SearchViewModel.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//

import Foundation
import Combine

enum SearchViewState: Equatable {
    case showingDefault
    case searching(String)
}
class SearchViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                state = .showingDefault
            } else {
                state = .searching(searchText)
                performSearch(for: searchText)
            }
        }
    }

    @Published var state: SearchViewState = .showingDefault
    
    @Published var searchResults: [Shops] = []

   

    func performSearch(for keyword: String) {
        searchResults = Shops.dummyList.filter {
            $0.name.localizedCaseInsensitiveContains(keyword)
        }
    }
}
