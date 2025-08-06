//
//  SearchKeywordManager.swift
//  VINNY
//
//  Created by 소민준 on 8/2/25.
//

import Foundation

final class SearchKeywordManager {
    static let shared = SearchKeywordManager()
    private init() {}

    private let key = "recent_keywords"

    func add(_ keyword: String) {
        var keywords = self.get()
        keywords.removeAll(where: { $0 == keyword }) // 중복 제거
        keywords.insert(keyword, at: 0) // 맨 앞에 삽입
        if keywords.count > 10 {
            keywords = Array(keywords.prefix(10))
        }
        UserDefaults.standard.set(keywords, forKey: key)
    }

    func get() -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func remove(_ keyword: String) {
        var keywords = self.get()
        keywords.removeAll { $0 == keyword }
        UserDefaults.standard.set(keywords, forKey: key)
    }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
